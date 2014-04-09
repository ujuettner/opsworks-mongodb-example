opsworks-mongodb-example
========================

Using the [mongodb community cookbook](http://community.opscode.com/cookbooks/mongodb) to set up a [MongoDB](http://www.mongodb.org/) replicat set within an [AWS OpsWorks](http://aws.amazon.com/opsworks/) custom layer.

Inspired by the blog post [Deploying MongoDB with OpsWorks](http://blogs.aws.amazon.com/application-management/post/Tx1RB65XDMNVLUA/Deploying-MongoDB-with-OpsWorks).

1. In AWS OpsWorks create a stack with the following properties:
  * Chef version: 11.10
  * Use custom Chef cookbooks: yes
  * Repository type: Git
  * Repository URL: https://github.com/ujuettner/opsworks-mongodb-example.git
  * Manage Berkshelf: yes
  * Berkshelf version: 2.0.14
  * Custom JSON:
  ```json
  {
    "mongodb": {
      "app_name": "todo_express",
      "config": {
        "replSet": "todors"
      }
    },
    "opsworks": {
      "data_bags": {
        "mongodb": {
          "mongodb1": {
            "mongodb": {
              "config": {
                "port": 27017
              },
              "replica_build_indexes": true,
              "replica_slave_delay": 0,
              "replica_priority": 1,
              "replica_tags": {},
              "replica_votes": 1
            }
          },
          "mongodb2": {
            "mongodb": {
              "config": {
                "port": 27017
              },
              "replica_build_indexes": true,
              "replica_slave_delay": 0,
              "replica_priority": 1,
              "replica_tags": {},
              "replica_votes": 1
            }
          },
          "mongodb3": {
            "mongodb": {
              "config": {
                "port": 27017
              },
              "replica_build_indexes": true,
              "replica_slave_delay": 0,
              "replica_priority": 1,
              "replica_tags": {},
              "replica_votes": 1
            }
          },
  ...
        }
      }
    }
  }
  ```
2. Add a custom layer, name it `mongodb` and add the following Custom Chef Recipes:
  * Setup: `server`
  * Configure: `mongodb::replicaset`
3. Add a Node.js App Server layer and add `client::deploy` as Custom Chef Recipe for the Deploy lifecycle event.
4. Add an app with the following properties:
  * Name: `todo-express`
  * Short name: `todo_express`
  * Type: Node.js
  * App source type: Git
  * Repository URL: https://github.com/ujuettner/todo-express.git

Using Chef 11.10 is required, as [Berkshelf](http://berkshelf.com/), search and data bags are used:
  * Berkshelf is used to load the mongodb community cookbook.
  * Using search to find all online nodes within the `mongodb` layer.
  * Data bags to store required properties for the found nodes - as there's no Chef Server as central storage of such properties, a data bag is used.
  * `mongodb/definitions/mongodb.rb` is an overriding copy from the mongodb community cookbook to implement our special search query and to retreive the required properties from the data bag.
