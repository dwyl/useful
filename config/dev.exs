use Mix.Config

# add pre-commit to run tests: 
config :pre_commit, commands: ["format", "test", "coveralls.html"]
