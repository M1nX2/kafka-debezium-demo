curl -s -S -XPOST -H Accept:application/json -H Content-Type:application/json http://localhost:8083/connectors/ -d @debezium-config.json
curl -s -S -XPOST -H Accept:application/json -H Content-Type:application/json http://localhost:8083/connectors/ -d @ms-sql-connector.json
docker exec -it kafka kafka-topics --create --topic schema-changes.productsdb --bootstrap-server kafka:29092 --partitions 1 --replication-factor 1
