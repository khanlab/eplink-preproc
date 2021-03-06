


def get_resources(wildcards, resources, threads): 

    app_type = resources.app_type
    
    if app_type == 'snakemake':
        return f"--resources mem_mb={resources.mem_mb} --cores {threads}"
    elif app_type == 'nipype':
        return f"--work-dir {config['global_app_opts']['tmp']} --mem {resources.mem_mb} --nprocs {threads} --omp-nthreads {threads}"
    else:
        return ""

def get_cmd_rsync_from_tmp(root,out_tmp,app):
    rsync_cmds = list()
    rsync_maps = app_config[app]['rsync_maps']

    for map_from in rsync_maps.keys():
        map_to = rsync_maps[map_from]
        
        map_from_folder = f'{out_tmp}/{map_from}'
        map_to_folder = f'{root}/{map_to}'

        rsync_cmds.append(f"mkdir -p {map_to_folder}")
        rsync_cmds.append(f"rsync -rltv {map_from_folder} {map_to_folder}")
    return ' && '.join(rsync_cmds)


def get_outputs(root,app):
    
    outputs = list()
    if 'dirs' in app_config[app]['outputs'].keys():
        for dir in app_config[app]['outputs']['dirs']:
            outputs.append(directory(f'{root}/{dir}'))

    if 'files' in app_config[app]['outputs'].keys():
        for file in app_config[app]['outputs']['files']:
            outputs.append(f'{root}/{file}')

    return outputs
 

rule create_deriv_dataset_json:
    input: 
        dir = lambda wildcards: expand('preproc/site-{site}/{app}/sub-{subject}',site=wildcards.site, subject=subjects[wildcards.site],allow_missing=True),
        json = 'resources/dataset_description_derivatives_template.json'
    output:
        json = 'preproc/site-{site}/{app}/dataset_description.json'
    shell: 'cp {input.json} {output.json}'

for app in apps:

    root = f'preproc/site-{{site}}/{app}'
    out_tmp = f'{app_tmp}/{root}/sub-{{subject}}'
    
    rule:
        input: 
            bids_dir = lambda wildcards: config['bids_dir'][wildcards.site]
        name: app
        params:
            out_tmp = out_tmp,
            command = app_config[app]['command'],
            app_opts = app_config[app]['opts'],
            resources_opts = get_resources,
            rsync_cmds = get_cmd_rsync_from_tmp(root,out_tmp,app)
        output: get_outputs(root,app)
        threads: app_config[app]['threads']
        resources: **app_config[app]['resources']
        shell: 
            "{params.command} {input.bids_dir} {params.out_tmp} participant --participant_label {wildcards.subject} {params.app_opts} {params.resources_opts}  && "
            " {params.rsync_cmds} "


    
