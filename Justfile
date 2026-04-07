# Run all tests
test:
    fish -c 'fishtape tests/*.fish'

# Run specific test file
test-file file:
    fish -c 'fishtape {{file}}'

# Launch interactive demo session with lophius loaded
demo:
    fish scripts/demo.fish
