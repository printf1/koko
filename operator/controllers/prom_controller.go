/*
Copyright 2021.

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
	promv1 "Gin/api/v1"
	"context"
	"encoding/json"
	"github.com/go-logr/logr"
	appsv1 "k8s.io/api/apps/v1"
	v1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"reflect"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
)

// PromReconciler reconciles a Prom object
type PromReconciler struct {
	client.Client
	Log    logr.Logger
	Scheme *runtime.Scheme
}

//+kubebuilder:rbac:groups=prom.my.domain,resources=proms,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=prom.my.domain,resources=proms/status,verbs=get;update;patch
//+kubebuilder:rbac:groups=prom.my.domain,resources=proms/finalizers,verbs=update

// Reconcile is part of the main kubernetes reconciliation loop which aims to
// move the current state of the cluster closer to the desired state.
// TODO(user): Modify the Reconcile function to compare the state specified by
// the Prom object against the actual cluster state, and then
// perform operations to make the cluster state reflect the state specified by
// the user.
//
// For more details, check Reconcile and its Result here:
// - https://pkg.go.dev/sigs.k8s.io/controller-runtime@v0.7.2/pkg/reconcile
func (r *PromReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	_ = r.Log.WithValues("prom", req.NamespacedName)
	// your logic here, 不断watch资源的状态，根据状态的不同去实现各种操作逻辑
	instance := &promv1.Prom{}
	err := r.Client.Get(ctx, req.NamespacedName, instance)
	if err != nil {
		if errors.IsNotFound(err) {
			return ctrl.Result{}, nil
		}
		return ctrl.Result{}, err
	}
	if instance.DeletionTimestamp != nil {
		return ctrl.Result{}, err
	}
	//如果不存在，则创建资源，如果存在则判断是否需要更新，如果需要更新，则直接更新，如果不需要更新，则正常返回
	//newdeploy newservice根据crd中的声明去填充祈愿的spec对象
	deploy := &appsv1.Deployment{}
	if err1 := r.Client.Get(ctx, req.NamespacedName, deploy); err1 != nil {
		//创建deploy
		deploy := newDeploy(instance)
		if err := r.Client.Get(ctx, req.NamespacedName, deploy); err != nil {
			return ctrl.Result{}, err
		}
		//创建service
		service := newService(instance)
		if err := r.Client.Get(ctx, req.NamespacedName, service); err != nil {
			return ctrl.Result{}, err
		}
		//关联annotations
		data, _ := json.Marshal(instance.Spec)
		if instance.Annotations != nil {
			//更新
			instance.Annotations["spec"] = string(data)
		} else {
			//创建
			instance.Annotations = map[string]string{"spec": string(data)}
		}
		if err := r.Client.Update(ctx, instance); err != nil {
			return ctrl.Result{}, err
		}
		return ctrl.Result{}, nil
	}
	oldspec := &promv1.Prom{}
	if err := json.Unmarshal([]byte(instance.Annotations["spec"]), oldspec); err != nil {
		return ctrl.Result{}, err
	}
	if !reflect.DeepEqual(instance.Spec, oldspec) {
		//关联新资源
		newDeploy := newDeploy(instance)
		oldDeploy := &appsv1.Deployment{}
		if err := r.Client.Get(ctx, req.NamespacedName, oldDeploy); err != nil {
			return ctrl.Result{}, err
		}
		oldDeploy.Spec = newDeploy.Spec
		if err := r.Client.Update(ctx, oldDeploy); err != nil {
			return ctrl.Result{}, err
		}
		newService := newService(instance)
		oldService := &v1.Service{}
		if err := r.Client.Get(ctx, req.NamespacedName, oldService); err != nil {
			return ctrl.Result{}, err
		}
		oldService = newService
		if err := r.Client.Update(ctx, oldService); err != nil {
			return ctrl.Result{}, err
		}
		return ctrl.Result{}, nil
	}
	return ctrl.Result{}, nil
}

func newDeploy(app *promv1.Prom) *appsv1.Deployment {
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
				}),
			},
		},
		Spec: appsv1.DeploymentSpec{
			Replicas: app.Spec.Size,
			Template: v1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Labels: labels,
				},
				Spec: v1.PodSpec{
					Containers: newContainers(app),
				},
			},
			Selector: selector,
		},
	}
}

func newContainers(app *promv1.Prom) []v1.Container {
	containerPorts := []v1.ContainerPort{}
	for _, svcPort := range app.Spec.Ports {
		cport := v1.ContainerPort{}
		cport.ContainerPort = svcPort.TargetPort.IntVal
		containerPorts = append(containerPorts, cport)
	}
	return []v1.Container{
		{
			Name:            app.Name,
			Image:           app.Spec.Image,
			Resources:       app.Spec.Resources,
			Ports:           containerPorts,
			ImagePullPolicy: v1.PullIfNotPresent,
			Env:             app.Spec.Envs,
		},
	}

}

func newService(app *promv1.Prom) *v1.Service {
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
func (r *PromReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&promv1.Prom{}).
		Complete(r)
}
