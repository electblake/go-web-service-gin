server_pid=

# start server and wait to be ready
# inspired by https://unix.stackexchange.com/a/322555/122447
setup_file() {
    echo "setup_file"
    output=$(mktemp "${TMPDIR:-/tmp/}$(basename 0).XXX")
    server &> $output &
    server_pid=$!
    echo "go run server pid: $server_pid" >&3
    echo " - output: $output" >&3
    echo " - wait..." >&3
    until grep -q -i 'localhost:8080' $output
    do       
      if ! ps $server_pid > /dev/null 
      then
        echo "< The server died" >&3
        exit 1
      fi
      echo -n "."
      sleep 1
    done
    echo 
    echo "> Server is running, test:"  >&3
}

# load test_helpers
function setup() {
    load "./test/test_helper/bats-assert/load"
    load "./test/test_helper/bats-support/load"
}

server() {
    go run .
}

# kill all background jobs
# inspired by https://stackoverflow.com/a/14697034/253608
function teardown_file() {
    for child in $(jobs -p); do
        echo kill "$child" >&3 && kill "$child"
    done
    wait $(jobs -p)
}

@test "get albums" {
    run http localhost:8080/albums
    echo "  - status: $status" >&3
    assert_equal $(echo $output | jq -r '.[2].id') 3
}

@test "get album by id" {
    run http localhost:8080/albums/2
    echo "  - status: $status" >&3
    assert_equal $status 0
    # check we got expected id
    assert_equal $(echo $output | jq -r '.id') 2
}

@test "post albums" {
    run http localhost:8080/albums < ./test/item416.json
    echo "  - status: $status" >&3
    assert_equal $status 0

    # get created item
    assert_equal $(http localhost:8080/albums | jq -r '.[3].id') 416
    
    # test creation response
    price=$(http localhost:8080/albums < ./test/item514.json | jq -r '.price')
    assert_equal $price 5140
    # if http --check-status localhost:8080/albums &> /dev/null; then
    # else
    #     case $? in
    #         2) echo 'Request timed out!' && exit 1 ;;
    #         3) echo 'Unexpected HTTP 3xx Redirection!'  && exit 1;;
    #         4) echo 'HTTP 4xx Client Error!'  && exit 1;;
    #         5) echo 'HTTP 5xx Server Error!'  && exit 1;;
    #         6) echo 'Exceeded --max-redirects=<n> redirects!'  && exit 1;;
    #         *) echo 'Other Error!'  && exit 1;;
    #     esac
    # fi
}


@test "delete album by id" {
    run http delete localhost:8080/albums/2
    echo "  - status: $status" >&3
    assert_equal $status 0
    assert_equal $(echo $output | jq -r '.success') true
    # check deleted id
    assert_equal $(echo $output | jq -r '.deleted') 2
}