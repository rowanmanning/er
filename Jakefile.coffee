
# Dependencies
colors = require 'colors'
{exec} = require 'child_process'
path = require 'path'

# Paths
paths =
  config: './test/config'
  nodebin: './node_modules/.bin'
  src: './src'
  unitTest: './test/unit'

# Build JavaScript
desc 'This builds JavaScript from the CoffeeScript source'
task 'build', ->
  console.log 'Building JavaScript:'.cyan
  exec "#{paths.nodebin}/coffee -o ./lib ./src", (error, stdout, stderr) ->
    console.log (if error is null then stdout else stderr)

# Run CoffeeLint
desc 'This runs CoffeeLint on the CoffeeScript source'
task 'lint', ->
  console.log 'Linting:'.cyan
  exec getLintCommand(), (error, stdout, stderr) ->
    console.log (if stderr is '' then stdout else stderr)

# Run unit tests
desc 'This runs all unit tests'
task 'test', (filePath) ->
  if filePath?
    filePath = path.join paths.unitTest, filePath
    console.log "Running unit tests for #{filePath}:".cyan
  else
    console.log 'Running unit tests:'.cyan
  exec getTestCommand(path: filePath), (error, stdout, stderr) ->
    if error is null
      console.log stdout
    else
      console.log stderr
      fail()
    complete()
, async: true

# CI
desc 'This runs all tasks required for CI'
task 'ci', ['lint', 'test']

# Default task
task 'default', ['lint', 'test', 'build']

# Generate a lint command
getLintCommand = (options = {}) ->
  options.configFile ?= "#{paths.config}/coffeelint.json"
  "#{paths.nodebin}/coffeelint -rf #{options.configFile} #{paths.src}/** #{paths.unitTest}/**"

# Generate a test command
getTestCommand = (options = {}) ->
  options.ui ?= 'tdd'
  options.reporter ?= 'spec'
  options.path ?= paths.unitTest
  "#{paths.nodebin}/mocha --compilers coffee:coffee-script --ui #{options.ui} --reporter #{options.reporter} --colors --recursive #{options.path}"
