curl -s -S -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d @debezium-config.json http://localhost:8083/connectors
curl -s -S -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d @ms-sql-connector.json http://localhost:8083/connectors
curl -s -S -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d @products-sink-connector-ms-sql-replica.json http://localhost:8083/connectors
