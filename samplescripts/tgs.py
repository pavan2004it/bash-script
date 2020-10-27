import boto3
import click
elbList = boto3.client('elbv2')
rgapi = boto3.client('resourcegroupstaggingapi')
"""
def lst_targets(lbar):
    tgs = []
    tgroups = elbList.describe_target_groups(LoadBalancerArn=lbar)
    for tg in tgroups['TargetGroups']:
        targetgps = tg['TargetGroupArn']
        print(targetgps)
    return tgs
@click.group()
def cli():
    ""awssnapelb manages snapshots""
@cli.group('tgroups')
def tgroups():
    ""Commands for listing target groups based on loadbalancers""
@tgroups.command('listtgs')
@click.option('--lbar', default=None,help="only the elb's for the project (tag Project:<name>)")

def lst_tgroups(lbar):
    target_groups = lst_targets(lbar)
    for tg in target_groups:
        print(tg)

if __name__ == '__main__':
    cli()
"""
"""
def lst_tg(project):
    tgs = []
    resources = rgapi.get_resources(TagFilters=[{'Key':'Project','Values':[project]}],ResourceTypeFilters=['elasticloadbalancing:targetgroup'])
    for tg in resources['ResourceTagMappingList']:
        print(tg['ResourceARN'])
    return tgs

@click.group()
def cli():
    ""list the target groups""
@cli.group('tgroups')
def tgroups():
    "" Command for listing targetgroups""
@tgroups.command('list')
@click.option('--project', default=None,help="only the elb's for the project (tag Project:<name>)")

def list_tg(project):
    target_groups = lst_tg(project)
    for tg in target_groups:
        print(tg)

if __name__ == '__main__':
    cli()
"""

import boto3
import click
elbList = boto3.client('elbv2')
rgapi = boto3.client('resourcegroupstaggingapi')
def list_tg(lbname):
    target = []
    loadbalancers = elbList.describe_load_balancers(Names=[lbname])
    for lb in loadbalancers['LoadBalancers']:
        lbalancer = lb['LoadBalancerName']
        lbalancerarn = lb['LoadBalancerArn']
        tgs = elbList.describe_target_groups(LoadBalancerArn=lbalancerarn)
        for tg in tgs['TargetGroups']:
            targetgps = tg['TargetGroupArn']
            print(targetgps)
    return target

@click.group()
def cli():
    """list the target groups"""
@cli.group('tgroups')
def tgroups():
    """ Command for listing targetgroups"""
@tgroups.command('list')
@click.option('--lbname', default=None,help="only the elb's for the project (tag Project:<name>)")

def lst_tg(lbname):
    target_groups = list_tg(lbname)
    for tg in target_groups:
        print(tg)

if __name__ == '__main__':
    cli()
