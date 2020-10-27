import boto3
import click
ec2 = boto3.resource('ec2')

def filter_instances(project):
    instances = []
    if project:
        filters = [{'Name':'tag:Cost Center', 'Values':[project]}]
        instances = ec2.instances.filter(Filters=filters)
    else:
        instances = ec2.instances.all()

    return instances

def has_pending_snapshots(volume):
    snapshots = list(volume.snapshots.all())
    return snapshots and snapshots[0].state == 'pending'




@click.group()
def cli():
    """cli for managing snapshots"""

@cli.group('snapshots')
def snapshots():
    """command for snapshots"""

@snapshots.command('list')
@click.option('--project', default=None,help="only the snapshots for the project (tag Project:<name>)")
@click.option('--all', 'list_all', default=False, is_flag=True, help="List all the snapshots of each volume , and not just the recent one's")
def list_snapshots(project, list_all):
    "List Ec2 Snapshots"
    instances = filter_instances(project)
    for i in instances:
        for v in i.volumes.all():
            for s in v.snapshots.all():
		tags = {t['Key']: t['Value'] for t in s.tags or []}
                attributes = [s.id, v.id, i.id, s.state, s.progress, s.start_time.strftime("%c"), tags.get('Cost Center', '<no project>')]
                print(', '.join(attributes))
		if s.state == 'completed' and not list_all: break
    return


@cli.group('volumes')
def volumes():
    """Command for volumes"""
@volumes.command('list')
@click.option('--project', default=None,help="only the volumes for the project (tag Project:<name>)")
def list_volumes(project):
    instances = filter_instances(project)
    "List EC2 volumes"
    for i in instances:
        for v in i.volumes.all():
	    tags = {t['Key']: t['Value'] for t in v.tags or []}
            attributes = [v.id, i.id, v.state, str(v.size) + "GiB", v.encrypted and "Encrypted" or "Not Encrypted", tags.get('Cost Center', '<no project>')]
            print(', '.join(attributes))
    return

@cli.group('instances')
def instances():
    """Command for instances"""
@instances.command('snapshot', help='Create snapshots of all volumes')
@click.option('--project', default=None,help="only the instances for the project (tag Project:<name>)")
def create_snapshots(project):
    "Create snapshots for ec2 instances"
    instances = filter_instances(project)

    for i in instances:
        print("Stopping {0}...".format(i.id))
        i.stop()
        i.wait_until_stopped()
        for v in i.volumes.all():
	    if has_pending_snapshots(v):
                print(" Skipping {0}, snapshot already in progress".format(v.id))
                continue
            print("Creating snapshot of {0}".format(v.id))
            v.create_snapshot(Description="Created by pavan")
        print("Starting {0}...".format(i.id))
        i.start()
        i.wait_until_running()
    print("Jobs Done")
    return
	



@instances.command('list')
@click.option('--project', default=None,help="only the instances for the project (tag Project:<name>)")
def list_instances(project):
    instances = filter_instances(project)
    "List EC2 instances"
    for i in instances:
        tags = {t['Key']: t['Value'] for t in i.tags or []}
        attributes = [i.id,i.instance_type,i.state['Name'],i.placement['AvailabilityZone'],i.public_dns_name,tags.get('Cost Center', '<no project>')]
        print(', '.join(attributes))
    return

@instances.command('start')
@click.option('--project', default=None,help="only the instances for the project (tag Project:<name>)")
def stop_instances(project):
    instances = filter_instances(project)
    for i in instances:
        print("Starting{0}...".format(i.id))
        i.stop()
    return

@instances.command('stop')
@click.option('--project', default='Devops',help="only the instances for the project (tag Project:<name>)")
def stop_instances(project):
    instances = filter_instances(project)
    for i in instances:
        print("Stopping{0}...".format(i.id))
        i.stop()
    return



if __name__ == '__main__':
    cli()




