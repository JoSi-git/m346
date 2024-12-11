
shutdown instances:

aws ec2 terminate-instances --instance-ids "instance ID"

show important instance info:
aws ec2 describe-instances --query "Reservations[*].Instances[*].{InstanceId:InstanceId, PublicIP:PublicIpAddress, State: State.Name}"