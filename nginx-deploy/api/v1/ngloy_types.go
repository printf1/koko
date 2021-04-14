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

package v1

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// EDIT THIS FILE!  THIS IS SCAFFOLDING FOR YOU TO OWN!
// NOTE: json tags are required.  Any new fields you add must have json tags for the fields to be serialized.

// NgloySpec defines the desired state of Ngloy
type NgloySpec struct {
	// INSERT ADDITIONAL SPEC FIELDS - desired state of cluster
	// Important: Run "make" to regenerate code after modifying this file

	// Foo is an example field of Ngloy. Edit ngloy_types.go to remove/update
	//Foo string `json:"foo,omitempty"`
	//CPU    string `json:"cpu"` // 这是我增加的
	//Memory string `json:"memory"`
	Size      *int32                      `json:"size"`
	Image     string                      `json:"image"`
	Resources corev1.ResourceRequirements `json:"resources,omitempty"`
	//Envs      []corev1.EnvVar             `json:"envs"`
	Ports []corev1.ServicePort `json:"ports,omitempty"`
}

// NgloyStatus defines the observed state of Ngloy
type NgloyStatus struct {
	// INSERT ADDITIONAL STATUS FIELD - define observed state of cluster
	// Important: Run "make" to regenerate code after modifying this file
	appsv1.DeploymentStatus `json:",inline"`
}

//+kubebuilder:object:root=true
//+kubebuilder:subresource:status

// Ngloy is the Schema for the ngloys API
type Ngloy struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   NgloySpec   `json:"spec,omitempty"`
	Status NgloyStatus `json:"status,omitempty"`
}

//+kubebuilder:object:root=true

// NgloyList contains a list of Ngloy
type NgloyList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []Ngloy `json:"items"`
}

func init() {
	SchemeBuilder.Register(&Ngloy{}, &NgloyList{})
}
