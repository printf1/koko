/*
Copyright 2021 https://github.com/RealGaohui.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package controllers

import (
	nginxcomv1 "Gin/api/v1"
	"context"
	"encoding/json"
	"fmt"
	"github.com/go-logr/logr"
	appsv1 "k8s.io/api/apps/v1"
	v1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"reflect"
	//"k8s.io/client-go/util/workqueue"
	"log"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
)

// NgloyReconciler reconciles a Ngloy object
type NgloyReconciler struct {
	client.Client
	Log    logr.Logger
	Scheme *runtime.Scheme
}

//+kubebuilder:rbac:groups=nginx.com.kblog.club,resources=ngloys,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=nginx.com.kblog.club,resources=ngloys/status,verbs=get;update;patch
//+kubebuilder:rbac:groups=nginx.com.kblog.club,resources=ngloys/finalizers,verbs=update

// Reconcile is part of the main kubernetes reconciliation loop which aims to
// move the current state of the cluster closer to the desired state.
// TODO(user): Modify the Reconcile function to compare the state specified by
// the Ngloy object against the actual cluster state, and then
// perform operations to make the cluster state reflect the state specified by
// the user.
//
// For more details, check Reconcile and its Result here:
// - https://pkg.go.dev/sigs.k8s.io/controller-runtime@v0.7.2/pkg/reconcile
func (r *NgloyReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	_ = r.Log.WithValues("ngloy", req.NamespacedName)
	// your logic here
	nginx := &nginxcomv1.Ngloy{}
	err := r.Client.Get(ctx, req.NamespacedName, nginx)
	if err != nil {
		if errors.IsNotFound(err) {
			log.Println("Unable to fetch nginx deployment")
			return ctrl.Result{}, err
		}
	}
	if nginx.DeletionTimestamp != nil {
		return ctrl.Result{}, err
	}

	//return ctrl.Result{}, nil

	log.Println("Deployment is not exist, Now Creating...")
	deploy := &appsv1.Deployment{}
	if err := r.Client.Get(ctx, req.NamespacedName, deploy); err != nil && errors.IsNotFound(err) {
		//创建
		deploy := newDeploy(nginx)
		if err := r.Client.Create(ctx, deploy); err != nil {
			log.Printf("Creating Deployment Error: %s", err)
			return ctrl.Result{}, err
		}
		log.Println("Creating Deploy Successful")
		//创建service
		service := newService(nginx)
		log.Println("Creating Service...")
		if err := r.Client.Create(ctx, service); err != nil {
			log.Printf("Creating Service Error: %s", err)
			return ctrl.Result{}, err
		}
		log.Println("Creating Service Successful")
		ann, err := json.Marshal(nginx.Spec)
		fmt.Printf("ann: %s\n, spec: %v", ann, nginx.Spec)
		if err != nil {
			log.Println(err)
		}
		if nginx.Annotations != nil {
			nginx.Annotations["spec"] = string(ann)
			log.Println("Updating Ann Successful")
		} else {
			nginx.Annotations = map[string]string{"spec": string(ann)}
			log.Println("Creating Ann Successful")
		}
		if err := r.Client.Update(ctx, nginx); err != nil {
			return ctrl.Result{}, err
		}
		return ctrl.Result{}, nil
	}
	//更新
	//这里要获取期望状态:nginxObj
	/*
		old := &nginxcomv1.NgloyList{}
		if err := r.Client.List(ctx, old); err != nil {
			log.Println("Enable to get PodList...")
			return ctrl.Result{}, err
		}
		for _, i := range old.Items {

		}
			//labels := map[string]string{"app": nginx.Name}
			//nginxObj := &nginxcomv1.Ngloy{}


	*/
	log.Println("Getting The Virtual Condition...")
	old := &nginxcomv1.NgloySpec{}
	if err := json.Unmarshal([]byte(nginx.Annotations["spec"]), old); err != nil {
		return ctrl.Result{}, err
	}
	if !reflect.DeepEqual(nginx, old) {
		log.Println("State Inconsistency, Updating...")
		newDep := newDeploy(nginx)
		oldDep := &appsv1.Deployment{}
		if err := r.Client.Get(ctx, req.NamespacedName, oldDep); err != nil {
			return ctrl.Result{}, err
		}
		oldDep.Spec = newDep.Spec
		if err := r.Client.Update(ctx, oldDep); err != nil {
			return ctrl.Result{}, err
		}
		newSvc := newService(nginx)
		oldSvc := &v1.Service{}
		if err := r.Client.Get(ctx, req.NamespacedName, oldSvc); err != nil {
			return ctrl.Result{}, err
		}
		oldSvc.Spec = newSvc.Spec
		if err := r.Client.Update(ctx, oldSvc); err != nil {
			return ctrl.Result{}, err
		}
		log.Println("updating Successful..")
	}
	log.Println("State is Consistent, No Operation...")
	return ctrl.Result{}, nil

	//删除
	//如果DeleteionTimestamp不存在
	//    如果没有Finalizers
	//       加上Finalizers,并更新CRD
	//要不然，说明是要被删除的
	//    如果存在Finalizers，删除Finalizers,并更新CRD
	//if nginxObj.ObjectMeta.DeletionTimestamp.IsZero() {

	//} else {

	//}
}

func newDeploy(app *nginxcomv1.Ngloy) *appsv1.Deployment {
	labels := map[string]string{"app": app.Name}
	selector := &metav1.LabelSelector{MatchLabels: labels}
	return &appsv1.Deployment{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "apps/v1",
			Kind:       "Deployment",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      app.Name,
			Namespace: app.Namespace,
			OwnerReferences: []metav1.OwnerReference{
				*metav1.NewControllerRef(app, schema.GroupVersionKind{
					Group:   v1.SchemeGroupVersion.Group,
					Version: v1.SchemeGroupVersion.Version,
					Kind:    "Ngloy",
				}),
			},
		},
		Spec: appsv1.DeploymentSpec{
			Replicas: app.Spec.Size,
			Selector: selector,
			Template: v1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Name:   app.Name,
					Labels: labels,
				},
				Spec: v1.PodSpec{
					Containers: newContainers(app),
				},
			},
		},
	}
}

func newContainers(app *nginxcomv1.Ngloy) []v1.Container {
	containerPorts := []v1.ContainerPort{}
	cport := v1.ContainerPort{}
	for _, svcPort := range app.Spec.Ports {
		cport.ContainerPort = svcPort.Port
		cport.Name = svcPort.Name
		cport.Protocol = svcPort.Protocol
		containerPorts = append(containerPorts, cport)
	}
	return []v1.Container{
		{
			Name:            app.Name,
			Image:           app.Spec.Image,
			Resources:       app.Spec.Resources,
			Ports:           containerPorts,
			ImagePullPolicy: v1.PullIfNotPresent,
			//Env:             app.Spec.Envs,
		},
	}

}

func newService(app *nginxcomv1.Ngloy) *v1.Service {
	/*
		svcports := []v1.ServicePort{}
		sport := v1.ServicePort{}
		for _, p := range app.Spec.Ports {
			sport.NodePort = p.NodePort
			sport.TargetPort = p.TargetPort
			sport.Protocol = p.Protocol
			svcports = append(svcports, sport)
		}

	*/
	return &v1.Service{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Service",
			APIVersion: "v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      app.Name,
			Namespace: app.Namespace,
			OwnerReferences: []metav1.OwnerReference{
				*metav1.NewControllerRef(app, schema.GroupVersionKind{
					Group:   v1.SchemeGroupVersion.Group,
					Version: v1.SchemeGroupVersion.Version,
					Kind:    "Prom",
				}),
			},
		},
		Spec: v1.ServiceSpec{
			Type:  v1.ServiceTypeNodePort,
			Ports: app.Spec.Ports,
			Selector: map[string]string{
				"app": app.Name,
			},
		},
	}
}

// SetupWithManager sets up the controller with the Manager.
func (r *NgloyReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&nginxcomv1.Ngloy{}).
		Complete(r)
}
