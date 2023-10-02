# Log Monitor

## Description

This is a Rails app that provides the ability to do on-demand monitoring of logs in the `/var/log` directory on unix-based servers. 

It exposes a REST end point to fetch logs from the machine receiving the REST request. 

A _very_ basic UX is also provided to enter in the following parameters:
- filename
- number of lines
- keywords to filter on

to retrieve log entries for a particular log file.

## Usage
1. After starting a rails server in the terminal using the command `rails s`, go to `localhost:3000/api/v1`
2. Enter in the filename, number of lines and search keywords. 
- Filename is a required parameter
- Number of lines is optional. It will default to 10 lines.
- Search keywords is optional. If provided, results will be filtered by provided keyword(s)
3. Clicking on the `View log` button will display the results

![Alt text](app/assets/images/form.png?raw=true)r

![Alt text](app/assets/images/log_details.png?raw=true)

Alternatively, you can make a REST request as follows:
`/api/v1/logs?filename=<filename>&n=<num_lines>&filter=<search_keywords>`

Examples:
- `/api/v1/logs?filename=syslog&n=20&filter=CRON`
- `/api/v1/logs?filename=syslog`

## Tests
Tests can be found under the `/test` directory. All tests can be run using the command `rails test`

To run tests in a specific file, you can use the command
`rails test <path_to_file>`

For example,
`rails test test/services/log_viewer_test.rb`

## Design

1. Routes are provided in `config/routes.rb`. Two routes have been configured - one for the form to enter in the parameters, and one for displaying log entries

2. The `LogsController` (`app/controllers/api/v1/logs_controller.rb`) provides implementation for controller actions that routes are mapped to in `routes.rb`.

3. To fetch log entries, the `get_log` method in `LogsController` calls the `LogViewer` service (`app/services/log_viewer.rb`) that fetches n entries from the end of the requested log file.

4. Views under `app/views/api/v1/logs` control how the information is shown to the client.
- `index.erb` controls the display for route `/api/v1`
- `get_log.erb` controls the display for route `/api/v1/logs`

### Buffer size

Buffer size for file reads was chosen to be 8 KB. This is assuming we want to read around 20 lines from a log file most of the time. Rough calculation is given below:

Assuming space for 1 char = 1 byte.

Assuming 1 line in log file usually has around 250 characters, 250 char = 250 bytes.

Space for 20 lines = 20 * 250 = 5000 bytes ~= 5 KB.

Choosing a factor of 4, we use 8 KB.

This can be tuned for optimal read performance if the assumptions above do not hold / as our use case changes. If we want to read larger amounts of data, [128 KB](https://eklitzke.org/efficient-file-copying-on-linux) may be a good starting point

### Reading from end of file

Reads are performed in batches from the end of the file until desired number of lines have been read, instead of loading whole file into memory and then selecting n lines from the end. This will me much more efficient for large files (see Peformance section).

## Performance
Some benchmarking metrics are provided below to compare:
1. Reading whole file into memory using `readlines` method
2. Reading n bytes from end of file in batches.
   
These were obtained by using the [`benchmark` module](https://ruby-doc.org/stdlib-2.5.0/libdoc/benchmark/rdoc/Benchmark.html).

A test file with random text was generated for the purpose of this testing.
All times below are the elapsed real time, and are in seconds.

File size: 1.4 MB

| method        | time     | 
| -----         | -----    |    
| read_from_end | 0.000113 |
| readlines     | 0.014277 |

File size: 430 MB

| method        | time     | 
| -----         | -----    |    
| read_from_end | 0.000101 |
| readlines     | 4.263571 |

File size: 1.1 GB

| method        | time      | 
| -----         | -----     |    
| read_from_end |  0.000121 |
| readlines     | 10.107283 |

File size: 3 GB

| method        | time      | 
| -----         | -----     |    
| read_from_end | 0.000372 |
| readlines     | timeout   |
