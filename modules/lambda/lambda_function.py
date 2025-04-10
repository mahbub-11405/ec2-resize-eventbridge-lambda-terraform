import boto3
import time

def lambda_handler(event, context):
    instance_id = event['instance_id']
    target_type = event['target_type']

    ec2 = boto3.client('ec2')

    print(f"Stopping instance {instance_id}")
    ec2.stop_instances(InstanceIds=[instance_id])
    ec2.get_waiter('instance_stopped').wait(InstanceIds=[instance_id])
    
    print(f"Modifying instance type to {target_type}")
    ec2.modify_instance_attribute(
        InstanceId=instance_id,
        InstanceType={'Value': target_type}
    )

    # Delay to ensure modify is fully applied
    time.sleep(10)

    print(f"Starting instance {instance_id}")
    ec2.start_instances(InstanceIds=[instance_id])

    return {
        "status": "success",
        "instance_id": instance_id,
        "new_type": target_type
    }
