# TiDB server 系统初始化调研

## tidb-server 初始化
```bash
~/work/tidb/bin/tidb-server --store=tikv --path="127.0.0.1:2379"
```
`--path` : 指定 `pd` 的对外服务端口，可以理解成 `etcd` 的对外服务端口

## main 函数

`tidb-server` 的入口函数

```go
func main() {
	flag.Parse()
	if *version {
		fmt.Println(printer.GetTiDBInfo())
		os.Exit(0)
	}
	registerStores()
	registerMetrics()
	config.InitializeConfig(*configPath, *configCheck, *configStrict, reloadConfig, overrideConfig)
	if config.GetGlobalConfig().OOMUseTmpStorage {
		config.GetGlobalConfig().UpdateTempStoragePath()
		err := disk.InitializeTempDir()
		terror.MustNil(err)
		checkTempStorageQuota()
	}
	setGlobalVars()
	setCPUAffinity()
	setupLog()
	setHeapProfileTracker()
	setupTracing() // Should before createServer and after setup config.
	printInfo()
	setupBinlogClient()
	setupMetrics()
	createStoreAndDomain()
	createServer()
	signal.SetupSignalHandler(serverShutdown)
	runServer()
	cleanup()
	syncLog()
}
```

## config init 函数
```go
// InitializeConfig initialize the global config handler.
// The function enforceCmdArgs is used to merge the config file with command arguments:
// For example, if you start TiDB by the command "./tidb-server --port=3000", the port number should be
// overwritten to 3000 and ignore the port number in the config file.
func InitializeConfig(confPath string, configCheck, configStrict bool, reloadFunc ConfReloadFunc, enforceCmdArgs func(*Config)) {
	cfg := GetGlobalConfig()
	var err error
	if confPath != "" {
		if err = cfg.Load(confPath); err != nil {
			// Unused config item error turns to warnings.
			if tmp, ok := err.(*ErrConfigValidationFailed); ok {
				// This block is to accommodate an interim situation where strict config checking
				// is not the default behavior of TiDB. The warning message must be deferred until
				// logging has been set up. After strict config checking is the default behavior,
				// This should all be removed.
				if (!configCheck && !configStrict) || isAllDeprecatedConfigItems(tmp.UndecodedItems) {
					fmt.Fprintln(os.Stderr, err.Error())
					err = nil
				}
			}
		}

		terror.MustNil(err)
	} else {
		// configCheck should have the config file specified.
		if configCheck {
			fmt.Fprintln(os.Stderr, "config check failed", errors.New("no config file specified for config-check"))
			os.Exit(1)
		}
	}
	enforceCmdArgs(cfg)

	if err := cfg.Valid(); err != nil {
		if !filepath.IsAbs(confPath) {
			if tmp, err := filepath.Abs(confPath); err == nil {
				confPath = tmp
			}
		}
		fmt.Fprintln(os.Stderr, "load config file:", confPath)
		fmt.Fprintln(os.Stderr, "invalid config", err)
		os.Exit(1)
	}
	if configCheck {
		fmt.Println("config check successful")
		os.Exit(0)
	}
	StoreGlobalConfig(cfg)
}
```