import boto3
import click
import botocore
ec2 = boto3.resource('ec2')

def filter_instances(project,env):
    instances = []
    if project:
        filters = [{'Name':'tag:Cost Center', 'Values':[project]},{'Name':'tag:Environment','Values':[env]}]
        instances = list(ec2.instances.filter(Filters=filters))
    else:
        instances = ec2.instances.all()

    return instances



@click.group()
def cli():
    """Shotty manages snapshots"""

@cli.group('instances')
def instances():
    """Commands for instances"""
@instances.command('list')
@click.option('--project', default=None,
              help="Only instances for project (tag Project:<name>)")
@click.option('--env', default='Dev',
              help="Only instances for environment (tag Environment:<name>)")
def list_instances(project,env):
    "List EC2 instances"
    instances = filter_instances(project,env)

    for i in instances:
        tags = { t['Key']: t['Value'] for t in i.tags or [] }
        print(', '.join((
            i.id,
            i.instance_type,
            i.placement['AvailabilityZone'],
            i.state['Name'],
            i.public_dns_name,
            tags.get("Cost Center", '<no project>'),
            tags.get("Environment", '<no environment>')
            )))

    return



if __name__ == '__main__':
    cli()
