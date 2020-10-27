import boto3
import click
import botocore
ec2 = boto3.resource('ec2')
for i in instances:
        for v in i.volumes.all():
            for s in v.snapshots.all():
                attributes = [s.id, v.id, i.id, s.state, s.progress, s.start_time.strftime("%c")]
                print(', '.join(attributes))
return
