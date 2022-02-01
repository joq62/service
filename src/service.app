%% This is the application resource file (.app file) for the 'base'
%% application.
{application, service,
[{description, "Service application and cluster" },
{vsn, "0.0.1" },
{modules, 
	  [service,service_sup,service_app,service_server]},
{registered,[service]},
{applications, [kernel,stdlib]},
{mod, {service_app,[]}},
{start_phases, []},
{git_path,"https://github.com/joq62/service.git"},
{constraints,[]}
]}.
