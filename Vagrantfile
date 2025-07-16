VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/jammy64"

  config.vm.define "node1" do |node|
    node.vm.hostname = "node1"
    node.vm.network "private_network", ip: "192.168.56.11"
    node.vm.provider "virtualbox" do |vb|
      vb.name = "node1"
      vb.memory = 1024
      vb.cpus = 1
    end
  end

  ["node2", "node3"].each_with_index do |name, i|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: "192.168.56.1#{i + 2}"
      node.vm.provider "virtualbox" do |vb|
        vb.name = name
        vb.memory = 1024
        vb.cpus = 1
      end
    end
  end
end