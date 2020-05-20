# mysql-action

Options:

* mysql version:
  - description: 'Version of MySQL to use'
  - required: false
  - default: 'latest'
* mysql root password:
  - description: 'set a root password for the mysql instance'
  - required: false
  - default: 'sha256'
* test dir:
  - description: 'Directory where to find the test to execute'
  - required: false
  - default: '.'
* debug:
  - description: 'Enable script debug'
  - required: false
  - default: '0'

```
steps:
- uses: jordiprats/mysql-action@v1.0
  with:
    mysql version: '8.0'
```
