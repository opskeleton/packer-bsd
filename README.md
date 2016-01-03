# Intro

Building BSD based Vagrant boxes using packer.

# Usage 
To build freebsd 10.0:

```bash
$ packer build --only=virtualbox-iso freebsd-10.2-amd64.json 
```

To build trueos 10.1:

```bash
$ packer build --only=virtualbox-iso pcbsd-10.1-amd64.json
```

Using the boxes (we must use NFS and run a shell script to avoid the lack of shared folders):

```ruby
Vagrant.configure("2") do |config|

  bridge = ENV['VAGRANT_BRIDGE']
  bridge ||= 'eth0'
  env  = ENV['PUPPET_ENV']
  env ||= 'dev'

  config.vm.guest = :freebsd
  config.vm.box = 'freebsd-10' 
  config.vm.network :public_network, :bridge => bridge
  config.vm.network "private_network", ip: "10.0.1.10"
  config.vm.hostname = 'foo.local'

  # Use NFS as a shared folder
  config.vm.synced_folder ".", "/vagrant", :nfs => true, id: "vagrant-root"
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', 2048, '--cpus', 2]
  end

  config.vm.provision "shell", inline: 'cd /vagrant && ./run.sh'
end
```

# Copyright and license

Copyright [2014] [Ronen Narkis]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
