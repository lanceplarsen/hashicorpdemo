# hashicorpdemo
Bootstrap HashiCorp Demo

Hashicorp provides DevOps tools for the modern datacenter.  You can provision hybrid infrastructure, secure secrets across distributed applications, and run dynamic resources for modern applications.  This project will bootstrap the HashiCorp tools, and provide an end-to-end example on how to leverage them in your deployment.


## Getting Started
The goal of this project is to show the value of the HashiCorp suite with a functional example. This project is not intended to show best practices for HashiCorp production deployment i.e. config files, daemons, and especially distribution of Vault tokens. When you're done with the demo you'll have securely deployed a high-availability language translation app using HashiCorp's DevOps suite and SaltStack.

### Project DevOps Strategy

This project assumes you have some familiarity with the HashiCorp suite of products, and configuration management. You can read more about the HashiCorp tools and what they can do here: https://www.hashicorp.com/devops-defined/ . These tools integrate well with existing configuration management software, and we will use SaltStack to help us install HashiCorp software on our cloud machines. You can read more about SaltStack here: https://saltstack.com/ . Puppet or another agent based CM tool (we need to collect machine details from the agents) could be used instead of SaltStack.

Here is a high-level breakout of each product's responsibility in our project:
- Packer - Prepackage our SaltMaster. All other machines depend on this instance for configuration.
- Terraform - Build our app infasturcutre. Load balancers, Docker Engines, etc., for the translate app.
- SaltStack - Install HashiCorp's runtime tools on the app infrastructure.
- Consul - Allow our translate app services to easily discover one another.
-  Nomad - Run the translate app container job. Support automatic registration of app services.
-  Vault - Inject credentials/secrets into the application at runtime.

### Application Architecture
- Salt-Master - Handles all CM for app infra.
- Vault - Secret distribution at runtime to Consul and Nomad.
- Nomad - Single cluster server. Docker nodes get Nomad agent to support Nomad workloads.
- Consul - Single cluster server. All nodes get Consul agent. Auto bootstrap with GCE metadata tags. 
- Nginx - Front end load balancer for traffic to our translate app.
- Docker (3x) - Runs the backend Docker containers for the translate app.

### Prerequisites

##### Software to install locally
(1) - Docker - https://docs.docker.com/docker-for-windows/install/#download-docker-for-windows
(2) - GCloud SDK - https://cloud.google.com/sdk/downloads
(3) - Packer - https://www.packer.io/downloads.html
(4) - Terraform - https://www.terraform.io/downloads.html

HashiCorp and SaltStack will do the rest on GCP.

##### Build and deploy the Docker container

Our application is a Node JS app that lives inside a Docker container.  You can find the Dockerfile in the node-translate folder.

We need to build the base container, tag it with repo info for our GCP project, and then push to the Container Registry.

```
docker build -t lance/nodetranslate .
docker tag lance/nodetranslate us.gcr.io/llarsen-hashicorp-demo/nodetranslate:latest
gcloud docker -- push us.gcr.io/llarsen-hashicorp-demo/nodetranslate:latest
```

Check your GCP project for the container. You should see it in the registry. We will make the registry public so Nomad can easily pull the image.  You can see Google's doc on how to do this here: https://cloud.google.com/container-registry/docs/access-control#serve_images_publicly

Check GCP cloud storage for your actual bucket name. You can see mine below.

```
gsutil defacl ch -u AllUsers:R gs://us.artifacts.llarsen-hashicorp-demo.appspot.com
gsutil acl ch -r -u AllUsers:R gs://us.artifacts.llarsen-hashicorp-demo.appspot.com
gsutil acl ch -u AllUsers:R gs://us.artifacts.llarsen-hashicorp-demo.appspot.com
```

###### Create an API Key for the container
The application uses the GCP Translate API to translate text for the user. To call this API we need to authenticate. There are multiple ways consume secure APIs on GCP. For this example we will create a simple API key. Follow this guide: https://support.google.com/cloud/answer/6158862?hl=en 

Once you have the key you can test the application locally. The key is stored in config.js. 

**************IF YOU TEST THE APP LOCALLY WITH A VALID API KEY AND DECIDE TO MAKE YOUR GCP CONTAINER REGISTRY PUBLIC DO NOT PUSH A VALID API KEY TO THE GCP CONTAINER REGISTRY. ANYONE WHO PULLS YOUR IMAGE CAN CALL APIs AGINSTA YOUR QUOTA WITH THE KEY.**************

###### Add your API Key template to cloud storage.

We need to add a template for Nomad to swap the dummy api-key with a valid api-key at container runtime. You can see an example of my template in the nomad/files folder in the salt-master folder. Make this file public in your storage bucket.


### Installing / Bootstrap

#### Step 1  - Packer

We will use Packer prepackage our Salt-Master server. It will contain both a Salt-Master and Salt-Minion. To install SaltStack, Packer will leverage the SaltStack bootstrap script: https://docs.saltstack.com/en/latest/topics/tutorials/salt_bootstrap.html

We could install SaltStack at Terraform runtime, but Terraform will block all the other machines from provisioning because the other machines require the IP of the Salt-Master. Below is an example showing this with Terraform's interpolation syntax. We save some time leveraging Packer to prepackage.

```
sudo sh bootstrap-salt.sh -A ${google_compute_instance.saltmaster.network_interface.0.address} git develop
```
We could have allowed cloud machines to discover the Salt-Master service through Consul, but in this environment we are installing ALL the HashiCorp software with SaltStack, so we need the other machines to discover the Salt-Master before Consul is available.

Do the following to create the custom Salt-Master image with Packer:

- Edit the variables in config.json to point to your project and GCP json key. Info on service account creds can be found here: https://cloud.google.com/storage/docs/authentication#generating-a-private-key .  The default compute service account will have privileges to create images, or you can create another service account with these privileges. 
- Put the json key in the packer/saltmaster-dev folder after you download it.
- Run the build with "packer build"

```
packer build -var-file=config.json saltmaster.json
```

After the build look for the following image in GCP: ubuntu-1604-xenial-v20170516-saltmaster-dev

#### Step 2 - Terraform

Now that we have created our custom image for the Salt-Master we can use Terraform to pull the vanilla images (ubuntu xenial) for the rest of our cloud machines and build our environment. Since we are using SaltStack to install our software, Terraform's main job is to put the infrastructure in the desired state. Once completed it will run SaltStack's bootstrap script to install our CM agents. Make note of the GCP metadata tags. We will use these later on our Salt-Master to provision by role.  Example below from the build file.

```
  tags         = ["docker"]
```

Do the following to run the Terraform build:
- Edit the variables.tf file to point to your GCP project and credentials
- Run "Terraform apply"

```
terraform apply
```

Check your instances in GCP. You should see eight machines:
- Consul Server
- Vault Server
- Nomad Server
- Salt-Master Server
- Nginx Server
- Docker Server (3x)

#### Step 3 - SaltStack

SSH to your Salt-Master, sudo su - (become root), and cd to /srv/salt. This is the parent folder for all of our SaltStack configurations. Our top file defines the configurations targeted to each server. Below is an example for our Docker machines.

```
  'roles:docker':
  - match: grain
  - consul.docker
  - dns.dnsmasq
  - nomad.docker
  - docker.server
```

In this example all servers with the "Docker" role get a Consul agent and a Nomad agent, along with DNS changes to forward DNS requests to Consul. Last, we will ensure the Docker server is installed on the machine.

To pick up the roles we tagged using Terraform we need to use the GCP grain file. This file is not included with the standard install. I've added it to _grains. You can find it here: https://github.com/saltstack/salt-contrib/blob/master/grains/gce.py

Pick up the grains with the following command:

```
salt '*' saltutil.sync_grains
```

If it worked correctly you'll see something similar to this:

```
tf-vault-0.c.llarsen-hashicorp-demo.internal:
    - grains.gce
tf-docker-1.c.llarsen-hashicorp-demo.internal:
    - grains.gce
tf-docker-0.c.llarsen-hashicorp-demo.internal:
    - grains.gce
tf-nomad-0.c.llarsen-hashicorp-demo.internal:
    - grains.gce
tf-nginx-0.c.llarsen-hashicorp-demo.internal:
    - grains.gce
tf-docker-2.c.llarsen-hashicorp-demo.internal:
    - grains.gce
tf-consul-0.c.llarsen-hashicorp-demo.internal:
    - grains.gce
```

We now have the machines created, and we've picked up the roles provisioned by Terraform. Now we can start installing the HashiCorp software.

We need to install the HashiCorp tools in following order. We will have to do a few manual steps in between, but the tools will do most of the heavy lifting for you.

1. Consul (This is the backend storage for Vault)
2. Vault (Other HashiCorp tools depend on Vault creds/secrets in our project)
3. All other servers

##### Installing Consul Server
Run the following command to install Consul:
```
salt -G 'roles:consul' state.apply
```

SaltStack will install the Consul Web UI. It's available on port 8500. Check it out from the external IP of the Consul server.



##### Installing Vault Server
Run the following command to install Vault:
```
salt -G 'roles:vault' state.apply
```

Vault will start in sealed status. For first time use we need to unseal Vault and initialize it. We have scripts to help us with this.

Copy this folder to the Vault server and SSH into it. SaltStack is a powerful remote execution engine. We can copy files over from the master like so.
```
salt-cp -G 'roles:vault' vault/files/* /tmp/vault_init
```

Once the files are copied ssh to the Vault server. Do the following:

```
./setup_vault.sh
```

This will initialize the Vault and copy the Vault tokens to the Consul K/V store. Grab the root token from the KV store. You can find the Vault tokens we created in our init script at this path in the Consul WEB UI.

```
/ui/#/dc1/kv/service/vault/
```

With the root token we can we can work the vault server. I've provided a demo script to create the secrets back ends and polices our app needs. Run it like so with the root token:

```
./demo_configure.sh <root key>
```

With the backend created we can add our API-KEY from earlier that the translate app will use for API authentication.

```
vault write secret/api_keys/nodetranslate key=<api key>
```

A secure token delivery mechanism is out of scope for this project, so we'll hardcode the Vault token in a few places. Here are the files to update on the Salt-Master. Look for the Vault token and update it with the root Vault token.

```
/srv/salt/nginx/files/nginx_consul_template.service
/srv/salt/nomad/files/nomad_server.hcl
```


##### Installing Remaining  Servers

Now that we've updated our Vault tokens in the config files, we can push the desired state to the remaining servers.

```
salt '*' state.apply
```

### HashiCorp Runtime Config

We've created our infasturcutre and installed all the software. Now we can see the power of HashiCorp at runtime. Below are some interesting things to look at before we run the example.  You also need to modify the Nomad job file for your project. See the Nomad section for steps.

#### Consul
Consul is providing service discovery for our application. For Nginx, it will monitor health of backend services, in this example, our translate app. We can use another HashiCorp tool, Consul Template, to dynamically update the Nginx conf file based on the health of our backend services. Consul template will also dynamically generate SSL certs for us, leveraging Vault as PKI issuer. Pretty cool. You can see the Consul Template files below:

```
/srv/salt/nginx/files/cert.tpl
/srv/salt/nginx/files/nginx.tpl
/srv/salt/nginx/files/nginx_consul_template.service
```

#### Nomad

We've installed the Nomad agents on all of our Docker servers. The agents will register with the main Nomad server and alert the cluster that the Docker driver is available on these machines. When we run our Docker job, Nomad will distribute the load evenly amongst these servers. It will also register all running containers as a Consul service.

Check the job file and update the artifact stanza to grab the config file you updated earlier. Also update the image name to the docker image deployed to your project.  You can see excerpt below from my job. Notice the dns_servers  - our containers are using Consul's DNS on the Docker servers, which we've configured on a dummy loopback interface.

```
/srv/salt/nomad/files/node.nomad

artifact {
    source = "https://storage.googleapis.com/llarsen-hashicorp-bucket/nomad/api_config.tpl"
}

config {
    image = "us.gcr.io/llarsen-hashicorp-demo/nodetranslate:latest"
    volumes = ["new/config.js:/usr/src/app/config.js"]
    dns_servers = ["169.254.1.1"]
    port_map {
        app = 3000
    }
 }
```


#### Vault

Vault integrates well with Nomad and Consul. You can see examples of this integration in the last two sections. We are able to easily generate SSL certs and grab API keys when our application runs.

#### Putting it all together / Running the example

Our Salt-Master has a Nomad agent so we can run the job from there. To do this we need a Vault token tied to the api_policy we created in our demo_configure.sh script.  From the Vault server run the following command. 
```
vault token-create -policy="api_policy"
```

Grab the token vaule and run the following from the Salt-Master server.

```
export VAULT_TOKEN=<api policy token>
nomad nomad run nomad/files/node.nomad
```

That's it. Nomad will start the job, register the services, and map all ports on the container's host.You can see all Docker containers running the below command. Also check out the updated Nginx.conf file - it will reflect the running backend app services. If you go into a running container you can see the injected API key at /usr/src/app/config.js.

```
 salt -G 'roles:docker' cmd.run 'docker ps -a'
 salt -G 'roles:nginx' cmd.run 'cat /etc/nginx/nginx.conf'
```

The application will serve on the external IP of the Nginx server /nodetranslate on port 443 (https). Try it out and translate some text.


## Authors

* **Lance Larsen**

## Acknowledgments

* HashiCorp on GitHub
* zendesk - https://medium.com/zendesk-engineering/making-docker-and-consul-get-along-5fceda1d52b9
