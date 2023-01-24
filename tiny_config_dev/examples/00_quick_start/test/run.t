Good config

  $ ../quick_start.exe ../good_config.toml
  (Ok 8)

Bad config...has negative value for threads

  $ ../quick_start.exe ../bad_config.toml
  (Error ("config error: threads" "expected an int > 0, but got -1"))
