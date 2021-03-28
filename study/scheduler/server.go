package app

import (
	"fmt"
	"github.com/spf13/cobra"
	"net/http"
	"os"
    "context"
	//"net/http"
)

type Option func(framework.Registry) error
//func NewSchedulerCommand(registryOptions ...Option) *cobra.Command {
func NewSchedulerCommand() *cobra.Command {
	//opts, err1 := options.NewOptions()
	//if err1 != nil {
		//fmt.Println(err1)
	//}

	cmd := &cobra.Command{
		Use:   "kube-scheduler",
		Long:  "",
		Short: "",
		Run: func(cmd *cobra.Command, args []string) {
			if err := runCommand(cmd, opts, registryOptions...); err != nil {
				fmt.Println("hello, world")
				os.Exit(1)
			}
		},
	}
	return cmd

}

func runCommand(cmd *cobra.Command, opts *Options.Options, registryOptions ...Option) error {
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()

    cc, sched, err := Setup(ctx, opts, registryOptions...)
    if err != nil {
    	fmt.Println(err)
    	return err
	}
	return Run(ctx, cc, sched)
}
//////////Authentication,Authorizer为/vender/k8s.io/apiserver/pkg/authentication和authorization下的包///////////////
//k8s.io/component-base/configz
func Run(ctx context.Context, cc *schedulerserverconfig.CompletedConfig, sched scheduler.Scheduler) error {
	if cz, err := configz.New("componentconfig"); err == nil {
		cz.Set(cc.ComponentConfig)
	} else {
		return fmt.Errorf("unable to register configz: %s", err)
	}
	// Start up the healthz server.
	if cc.InsecureServing != nil {
	buildHandlerChain(newHealthzHandler(&cc.Component.Config), nil, nil)
	}
	if cc.InsecureMetricsServing != nil {
	buildHandlerChain(newMetricsHandler(&cc.Component.Config), nil, nil)
	}
	if cc.SecureServing != nil {
		buildHandlerChain(newHealthzHandler(&cc.component.Config, false, checks...), cc.Authentication.Authenticator, cc.Authentication.Authorizer)
	}
	return fmt.Errorf("errrr")
}
//////////genericapifilters，genericfilters为/vender/apiserver/endpoint，server/filter//////////////
func buildHandlerChain(handler http.Handler, authn authenicator.Request, authz authorizer.Autherizer) http.Handler {
    hendler = genericapifilters.WithAuthorization(handler, authz, legacyscheme.Codecs)
    handler = genericapifilters.WithAuthentication(handler, authn, failedHandler, nil)
    handler = gebericapifilters.WithRequestInfo(handler, requestInfoResolver)
    handler = genericapifilters.WithCacheControl(handler)
    handler = genericfilters.WithPAnicRecovery(handler)
    return handler
}
///////////mux,rooutes,healthz为/vender/apiserver/pkg/server的包////////////////
func newMetricsHandler(config *kubeschedulerconfig.KubeSchedulerConfigration) http.Handler {
	pathRecorderMux := mux.NewPathRecorderMux("kube-scheduler")
	installMetricHandler(pathRecorderMux)
	if config.EnableProfiling {
		routes.Profiling{}.Install(pathRecorderMux)
		if config.EnableContention	Profiling {
			goruntime.SetBlockProfileRate(1)
		}
		routes.DebugFlags{}.Install(pathRecorderMux, "v", routes.StringFlagPutHandler(logs.Glogsetter))
	}
	return pathRecorderMux
}

func newHealthzHandler(config *kubeschedulerconfig.KubeSchedulerConfigration, separateMetrics bool, checks ...healthz.HealthChecker) http.Handler {
	pathRecorderMux := mux.NewPathRecorderMux("kube-scheduler")
	healthz.InstallHandler(pathRecorderMux, checks...)
	if !separateMetrics {
		installMetricHandler(pathRecorderMux)
	}
	return pathRecorderMux
}
///////////mux,rooutes,healthz为/vender/apiserver/pkg/server的包////////////////
//k8s.io/component-base/configz
func installMetricHandler(pathRecorderMux *mux.PathRecorderMux) {
	configz.Installhandler(pathRecorderMux)
	defaultMetricsHandler := legacyRegistry.Handler().ServerHTTP
	pathRecorderMux.HandlerFunc("/metrics", func(w http.ResponseWriter, req *http.Request) {})
}

func getRecorderFactory(cc *schedulerserverconfig.CompletedConfig) profile.RecorderFactory {
	if _, err := cc.Client.Discovery().ServerResourcesForGroupVersion(eventsv1beta1.SchemeGroupVersion.String()); err == nil {
		cc.Broadcaster = events.NewBroadcaster(&events.EventSinkImpl{Interface: cc.EventClient.Events("")})
		return profile.NewRecorderFactory(cc.Broadcaster)
	}
	return func(name string) events.EventRecorder {
		r := cc.CoreBroadcaster.NewRecorder(scheme.Scheme, v1.EventSource{Component: name})
		return record.NewEventRecorderAdapter(r)
	}
}
// WithPlugin creates an Option based on plugin name and factory. Please don't remove this function: it is used to register out-of-tree plugins,
// hence there are no references to it from the kubernetes scheduler code base.
func WithPlugin(name string, factory framework.PluginFactory) Option {
	return func(registry framework.Registry) error {
		return registry.Register(name, factory)
	}
}

// Setup creates a completed config and a scheduler based on the command args and options
func Setup(ctx context.Context, opts *options.Options, outOfTreeRegistryOptions ...Option) (*schedulerserverconfig.CompletedConfig, *scheduler.Scheduler, error) {
	if errs := opts.Validate(); len(errs) > 0 {
		return nil, nil, utilerrors.NewAggregate(errs)
	}

	c, err := opts.Config()
	if err != nil {
		return nil, nil, err
	}

	// Get the completed config
	cc := c.Complete()

	outOfTreeRegistry := make(framework.Registry)
	for _, option := range outOfTreeRegistryOptions {
		if err := option(outOfTreeRegistry); err != nil {
			return nil, nil, err
		}
	}

	recorderFactory := getRecorderFactory(&cc)
	// Create the scheduler.
	sched, err := scheduler.New(cc.Client,
		cc.InformerFactory,
		cc.PodInformer,
		recorderFactory,
		ctx.Done(),
		scheduler.WithProfiles(cc.ComponentConfig.Profiles...),
		scheduler.WithAlgorithmSource(cc.ComponentConfig.AlgorithmSource),
		scheduler.WithPreemptionDisabled(cc.ComponentConfig.DisablePreemption),
		scheduler.WithPercentageOfNodesToScore(cc.ComponentConfig.PercentageOfNodesToScore),
		scheduler.WithBindTimeoutSeconds(cc.ComponentConfig.BindTimeoutSeconds),
		scheduler.WithFrameworkOutOfTreeRegistry(outOfTreeRegistry),
		scheduler.WithPodMaxBackoffSeconds(cc.ComponentConfig.PodMaxBackoffSeconds),
		scheduler.WithPodInitialBackoffSeconds(cc.ComponentConfig.PodInitialBackoffSeconds),
		scheduler.WithExtenders(cc.ComponentConfig.Extenders...),
	)
	if err != nil {
		return nil, nil, err
	}

	return &cc, sched, nil
}
