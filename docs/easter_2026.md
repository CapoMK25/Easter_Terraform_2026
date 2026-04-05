# Easter Grindset 2026 documentation

The Docker has now been set up and can be seen here:

```bash
root@798a86cbc583:/app/terraform# aws --endpoint-url=http://localstack:4566 ec2 describe-instances \
  --query 'Reservations[*].Instances[*].{ID:InstanceId,State:State.Name,Tag:Tags[0].Value}' \
  --output table
------------------------------------------------------------------
|                        DescribeInstances                       |
+----------------------+----------+------------------------------+
|          ID          |  State   |             Tag              |
+----------------------+----------+------------------------------+
|  i-5bdb4fb005eacb533 |  running |  EasterTerraform-Web-Server  |
+----------------------+----------+------------------------------+
root@798a86cbc583:/app/terraform#