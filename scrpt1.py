import boto3
import click
ec2 = boto3.resource('ec2')
elbList = boto3.client('elbv2')
def filter_instances(project):
    instances = []
    if project:
        filters = [{'Name':'tag:Project', 'Values':[project]}]
        instances = ec2.instances.filter(Filters=filters)
    else:
        instances = ec2.instances.all()

    return instances

def tar_instances(project):
    instances = []
    if project:
        filters = [{'Name':'tag:Project', 'Values':[project]}]
        instances = ec2.instances.filter(Filters=filters)
    else:
        instances = ec2.instances.all()

    return instances


def lst_targets(project):
     loadbalancers = elbList.describe_target_health(TargetGroupArn='arn:aws:elasticloadbalancing:eu-west-1:672985825598:targetgroup/test/4ae1eee6118aae2e')
     "list the targets"
     for target in loadbalancers['TargetHealthDescriptions']:
         target_id = target['Target']['Id']
         
     return target_id

@click.group()
def cli():
    """cli for managing snapshots"""
@cli.group('loadbalancers')
def loadbalancers():
    """Command for load balancers"""
@loadbalancers.command('listelbs')
@click.option('--project', default=None,help="only the elb's for the project (tag Project:<name>)")
def list_loadbalancers(project):
    loadbalancers = elbList.describe_load_balancers()
    "List the lb's"
    for elb in loadbalancers['LoadBalancers']:
        print('ELB Name : ' + elb['LoadBalancerName'])
    return

@loadbalancers.command('listtargetgroups')
@click.option('--project', default=None,help="only the targets for the project (tag Project:<name>)")
def list_targetgroups(project):
    loadbalancers = elbList.describe_target_groups()
    "List Targetgroups in the ELB"
    for elb in loadbalancers['TargetGroups']:
        print('ELB Target group Name : ' + elb['TargetGroupName'])
    return




@loadbalancers.command('removetargets')
@click.option('--project', default=None,help="only the targets for the project (tag Project:<name>)")

def rm_targets(project):
     target_id = lst_targets(project)
     Targets = []
     Target = {}
     Target['Id'] = target_id
     Targets.append(Target)
     lbs = elbList.deregister_targets(TargetGroupArn='arn:aws:elasticloadbalancing:eu-west-1:672985825598:targetgroup/test/4ae1eee6118aae2e',Targets=Targets)
     print(lbs)
     

@loadbalancers.command('addtargets')
@click.option('--project', default=None,help="only the targets for the project (tag Project:<name>)")

def add_targets(project):
     target_id = tar_instances(project)
     for i in target_id:
    	Targets = []
     	Target = {}
        Target['Id'] = i.id
        Target['Port'] = 80
     	Targets.append(Target)
     print(Targets)
     lbs = elbList.register_targets(TargetGroupArn='arn:aws:elasticloadbalancing:eu-west-1:672985825598:targetgroup/test/4ae1eee6118aae2e',Targets=Targets)
     print(lbs)
     



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
            attributes = [v.id, i.id, v.state, str(v.size) + "GiB", v.encrypted and "Encrypted" or "Not Encrypted"]
            print(', '.join(attributes))
    return

@cli.group('snapshots')
def snapshots():
    """command for snapshots"""

@snapshots.command('list')
@click.option('--project', default=None,help="only the snapshots for the project (tag Project:<name>)")
def list_snapshots(project):
    "List Ec2 Snapshots"
    instances = filter_instances(project)
    for i in instances:
        for v in i.volumes.all():
            for s in v.snapshots.all():
                attributes = [s.id, v.id, i.id, s.state, s.progress, s.start_time.strftime("%c")]
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
    print(instances)
    "List EC2 instances"
    for i in instances:
        tags = {t['Key']: t['Value'] for t in i.tags or []}
        attributes = [i.id,i.instance_type,i.state['Name'],i.placement['AvailabilityZone'],i.public_dns_name,tags.get('Project', '<no project>')]
        print(', '.join(attributes))
    return

@instances.command('start')
@click.option('--project', default='Devops',help="only the instances for the project (tag Project:<name>)")
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




