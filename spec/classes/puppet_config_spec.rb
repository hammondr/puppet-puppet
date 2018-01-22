require 'spec_helper'

describe 'puppet::config' do
  let(:node) { 'client.invalid' }
  let(:params) { { :config_path => '/etc/puppetlabs/puppet' } }

  context 'minimum case' do
    it 'manage puppet.conf' do
      should contain_file('puppet.conf').with(
        :path   => '/etc/puppetlabs/puppet/puppet.conf',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644'
      )
    end # manage puppet.conf

    it 'default values in puppet.conf' do
      should contain_file('puppet.conf').
        with_content(/^\s+environment = baz$/).
        with_content(/^\s+server      = server.invalid$/).
        with_content(/^\s+certname    = client.invalid$/)
    end # default values in puppet.conf
  end # minimum case

  ### agent ###

  context 'agent' do
    context 'on' do
      let(:params) { { 'agent' => true } }

      it 'have an [agent] block' do
        should contain_file('puppet.conf').with_content(/^\[agent\]$/)
      end # have an [agent] block
    end # on

    context 'off' do
      let(:params) { { 'agent' => false } }

      it 'no [agent] block' do
        should contain_file('puppet.conf').without_content(/^\[agent\]$/)
      end # no [agent] block
    end # off
  end # agent

  ### aliases ###

  context 'aliases' do
    context 'exist' do
      let(:params) { { 'aliases' => %w[foo bar] } }

      it 'dns_alt_names entry' do
        should contain_file('puppet.conf').
          with_content(/^\s+dns_alt_names = client.invalid, foo, bar$/)
      end
    end # exist

    context 'do not exist' do
      let(:params) { { 'aliases' => [] } }

      it 'no dns_alt_names entry' do
        should contain_file('puppet.conf').
          without_content(/^\s+dns_alt_names = .*$/)
      end
    end # do not exist

    context 'bad aliases' do
      let(:params) { { :aliases => 'foo' } }

      it do
        should raise_error(Puppet::Error, /expects an Array/)
      end
    end # bad aliases
  end # aliases

  ### autosign ###
  context 'autosign' do
    context 'enabled' do
      let(:params) { { :master => true, :is_ca => true, :autosign => 'testing' } }

      it 'enable autosign' do
        should contain_file('puppet.conf').
          with_content(/^\s+autosign\s+= testing$/)
      end # enable autosign
    end

    context 'disabled' do
      let(:params) { { :master => true, :is_ca => true, :autosign => '' } }

      it 'not enable autosign' do
        should contain_file('puppet.conf').
          without_content(/^\s+autosign\s+=.*$/)
      end # not enable autosign
    end

    context 'default' do
      let(:params) { { :master => true } }

      it 'not enable autosign' do
        should contain_file('puppet.conf').
          without_content(/^\s+autosign\s+=.*$/)
      end # not enable autosign
    end

    context 'bad' do
      let(:params) { { :autosign => false } }

      it 'fail' do
        should raise_error(Puppet::Error, /expects a String/)
      end # fail
    end
  end # autosign

  ### ca_server ###

  context 'ca_server' do
    context 'default' do
      it 'not have a ca_server set' do
        should contain_file('puppet.conf').
          without_content(/^\s+ca_server\s+= .*$/)
      end # not have a ca_server set
    end # default

    context 'valid' do
      let(:params) { { 'ca_server' => 'ca_server.invalid' } }

      it 'have a ca_server set' do
        should contain_file('puppet.conf').
          with_content(/^\s+ca_server\s+= ca_server.invalid$/)
      end # have a ca_server set
    end # valid

    context 'empty' do
      let(:params) { { 'ca_server' => '' } }

      it 'not have a ca_server set' do
        should contain_file('puppet.conf').
          without_content(/^\s+ca_server\s+= .*$/)
      end # not have a ca_server set
    end # empty

    context 'invalid' do
      let(:params) { { 'ca_server' => false } }

      it do
        should raise_error(Puppet::Error, /expects a String/)
      end
    end # invalid
  end # ca_server

  ### certname ###

  context 'certname' do
    context 'valid' do
      let(:params) { { 'certname' => 'foobar' } }

      it 'have a different certname' do
        should contain_file('puppet.conf').
          with_content(/^\s+certname    = foobar$/)
      end
    end

    context 'invalid' do
      let(:params) { { 'certname' => false } }

      it do
        should raise_error(Puppet::Error, /expects a String/)
      end
    end # invalid
  end # certname

  ### config_path ###

  context 'config_path' do
    context 'default' do
      let(:params) { { :master => true } }

      it do
        should contain_file('puppet.conf').
          with_content(/^# \/etc\/puppetlabs\/puppet\/puppet.conf$/)
      end
    end

    context 'valid' do
      let(:params) { { :master => true, :config_path => '/foo' } }

      it do
        should contain_file('puppet.conf').
          with_content(/^# \/foo\/puppet.conf$/)
      end
    end

    context 'invalid' do
      let(:params) { { :master => true, :config_path => false } }

      it { should raise_error(Puppet::Error, /expects a String/) }
    end
  end # config_path

  ### enc ###

  context 'enc' do
    context 'enabled' do
      let(:params) { { :master => true, :enc => 'testing' } }

      it 'enable enc' do
        should contain_file('puppet.conf').
          with_content(/^\s+node_terminus\s+= exec$/).
          with_content(/^\s+external_nodes\s+= testing$/)
      end # enable enc
    end

    context 'disabled' do
      let(:params) { { :master => true, :enc => '' } }

      it 'not enable enc' do
        should contain_file('puppet.conf').
          without_content(/^\s+node_terminus\s+= exec$/)
      end # not enable enc
    end

    context 'default' do
      let(:params) { { :master => true } }

      it 'not enable enc' do
        should contain_file('puppet.conf').
          without_content(/^\s+node_terminus \s+= exec$/)
      end # not enable enc
    end

    context 'bad' do
      let(:params) { { :enc => false } }

      it 'fail' do
        should raise_error(Puppet::Error, /expects a String/)
      end # fail
    end
  end # enc

  ### env ###

  context 'env' do
    context 'new env' do
      let(:params) { { :env => 'foo_bar' } }

      it 'updated environment' do
        should contain_file('puppet.conf').
          with_content(/^\s+environment = foo_bar$/)
      end # updated environment
    end # new env

    context 'empty env or nothing from hiera' do
      let(:params) { { 'env' => '' } }

      it do
        should raise_error(Puppet::Error, /expects a String\[1/)
      end
    end # no env

    context 'bad env type' do
      let(:params) { { :env => ['baz'] } }

      it do
        should raise_error(Puppet::Error, /expects a String/)
      end
    end # bad env type
  end

  ### envdir ###

  context 'envdir' do
    context 'default' do
      let(:params) { { :master => true } }

      it do
        should contain_file('puppet.conf').
          with_content(/^\s+environmentpath\s+= \/etc\/puppetlabs\/code\/environments$/)
      end
    end

    context 'valid' do
      let(:params) { { :master => true, :envdir => '/foo' } }

      it do
        should contain_file('puppet.conf').
          with_content(/^\s+environmentpath\s+= \/foo$/)
      end
    end

    context 'invalid' do
      let(:params) { { :master => true, :envdir => false } }

      it { should raise_error(Puppet::Error, /expects a String/) }
    end
  end # envdir

  ### env_timeout ###

  context 'env_timeout' do
    context 'default' do
      let(:params) { { :master => true } }

      it do
        should contain_file('puppet.conf').
          with_content(/^\s+environment_timeout\s+= 180$/)
      end
    end

    context 'valid' do
      let(:params) { { :master => true, :env_timeout => 1 } }

      it do
        should contain_file('puppet.conf').
          with_content(/^\s+environment_timeout\s+= 1$/)
      end
    end

    context 'invalid string' do
      let(:params) { { :master => true, :env_timeout => 'foo' } }

      it do
        should raise_error(Puppet::Error, /expects an Integer/)
      end
    end

    context 'invalid non-int' do
      let(:params) { { :master => true, :env_timeout => 1111.1 } }

      it do
        should raise_error(Puppet::Error, /expects an Integer/)
      end
    end

  end # env_timeout

  ### extra_agent ###

  context 'extra_agent' do
    context 'agent block' do
      let(:params) { { :agent => true, :extra_agent => %w[foo bar] } }

      it 'add items to agent block' do
        should contain_file('puppet.conf').
          with_content(/^\s+foo.*$/).
          with_content(/^\s+bar.*$/)
      end
    end

    context 'no agent block' do
      let(:params) { { :agent => false, :extra_agent => ['foo'] } }

      it do
        should contain_file('puppet.conf').without_content(/^\s+foo$/)
      end
    end

    context 'invalid non-Array' do
      let(:params) { { :extra_agent => 'foo' } }

      it do
        should raise_error(Puppet::Error, /expects an Array/)
      end
    end
  end # extra_agent

  ### extra_main ###

  context 'extra_main' do
    context 'main block' do
      let(:params) { { :extra_main => %w[foo bar] } }

      it 'add items to main block' do
        should contain_file('puppet.conf').
          with_content(/^\s+foo.*$/).
          with_content(/^\s+bar.*$/)
      end
    end

    context 'invalid non-Array' do
      let(:params) { { :extra_main => 'foo' } }

      it do
        should raise_error(Puppet::Error, /expects an Array/)
      end
    end
  end # extra_main

  ### extra_master ###

  context 'extra_master' do
    context 'master block' do
      let(:params) { { :master => true, :extra_master => %w[foo bar] } }

      it 'add items to master block' do
        should contain_file('puppet.conf').
          with_content(/^\s+foo.*$/).
          with_content(/^\s+bar.*$/)
      end
    end

    context 'no master block' do
      let(:params) { { :master => false, :extra_master => ['foo'] } }

      it do
        should contain_file('puppet.conf').without_content(/^\s+foo$/)
      end
    end

    context 'invalid non-Array' do
      let(:params) { { :extra_master => 'foo' } }

      it do
        should raise_error(Puppet::Error, /expects an Array/)
      end
    end
  end # extra_master

  ### is_ca ###

  context 'is_ca' do
    context 'on' do
      let(:params) { { :master => true, :is_ca => true } }

      it 'set ca = true' do
        should contain_file('puppet.conf').with_content(/^\s+ca\s+= true$/)
      end
    end

    context 'off' do
      let(:params) { { :master => true, :is_ca => false } }

      it 'set ca = true' do
        should contain_file('puppet.conf').with_content(/^\s+ca\s+= false$/)
      end
    end

    context 'default' do
      let(:params) { { :master => true } }

      it 'set ca = true' do
        should contain_file('puppet.conf').with_content(/^\s+ca\s+= false$/)
      end
    end

    context 'bad' do
      let(:params) { { :master => true, :is_ca => 'fish' } }

      it 'fail' do
        should raise_error(Puppet::Error, /expects a Boolean/)
      end # should fail
    end

  end # is_ca

  ### master ###

  context 'master' do
    context 'on' do
      let(:params) { { 'master' => true } }

      it 'have an [master] block' do
        should contain_file('puppet.conf').with_content(/^\[master\]$/)
      end # should have an [master] block
    end # on

    context 'off' do
      let(:params) { { 'master' => false } }

      it 'have no [master] block' do
        should contain_file('puppet.conf').without_content(/^\[master\]$/)
      end # should have no [master] block
    end # off
  end # master

  ### no_warnings ###

  context 'no_warnings' do
    context 'exist' do
      let(:params) { { 'no_warnings' => %w[foo bar] } }

      it 'have a disable_warnings entry' do
        should contain_file('puppet.conf').
          with_content(/^\s+disable_warnings = foo, bar$/)
      end
    end # exist

    context 'default' do
      it 'not have a disable_warnings entry' do
        should contain_file('puppet.conf').
          without_content(/^\s+disable_warnings =.*$/)
      end
    end # do not exist

    context 'do not exist' do
      let(:params) { { 'no_warnings' => [] } }

      it 'not have a disable_warnings entry' do
        should contain_file('puppet.conf').
          without_content(/^\s+disable_warnings =.*$/)
      end
    end # do not exist

    context 'bad no_warnings' do
      let(:params) { { :no_warnings => 'foo' } }

      it do
        should raise_error(Puppet::Error, /expects an Array/)
      end
    end # bad no_warnings
  end # no_warnings

  ### port ###

  context 'port' do
    context 'invalid string' do
      let(:params) { { :port => 'foo' } }

      it do
        should raise_error(Puppet::Error, /expects an Integer/)
      end
    end

    context 'invalid non-int' do
      let(:params) { { :port => '1111.1' } }

      it do
        should raise_error(Puppet::Error, /expects an Integer/)
      end
    end

    context 'valid' do
      let(:params) { { :port => 1111 } }

      it do
        should contain_file('puppet.conf')
      end
    end
  end

  ### reports ###

  context 'reports' do
    context 'exist' do
      let(:params) { { :master => true, :reports => %w[foo bar] } }

      it 'have a reports entry' do
        should contain_file('puppet.conf').
          with_content(/^\s+reports\s+= foo,bar$/)
      end
    end # exist

    context 'default' do
      let(:params) { { :master => true } }

      it 'not have a reports entry' do
        should contain_file('puppet.conf').
          without_content(/^\s+reports\s+=.*$/)
      end
    end # do not exist

    context 'do not exist' do
      let(:params) { { 'reports' => [] } }

      it 'not have a reports entry' do
        should contain_file('puppet.conf').
          without_content(/^\s+reports\s+=.*$/)
      end
    end # do not exist

    context 'bad reports' do
      let(:params) { { :reports => 'foo' } }

      it { should raise_error(Puppet::Error, /expects an Array/) }
    end # bad reports
  end # reports

  ### reporturl ###

  context 'reporturl' do
    context 'enabled' do
      let(:params) { { :master => true, :reporturl => 'testing' } }

      it 'enable reporturl' do
        should contain_file('puppet.conf').
          with_content(/^\s+reporturl\s+= testing$/)
      end # should enable reporturl
    end

    context 'disabled' do
      let(:params) { { :master => true, :reporturl => '' } }

      it 'not enable reporturl' do
        should contain_file('puppet.conf').
          without_content(/^\s+reporturl\s+= /)
      end # should not enable reporturl
    end

    context 'default' do
      let(:params) { { :master => true } }

      it 'not enable reporturl' do
        should contain_file('puppet.conf').
          without_content(/^\s+reporturl\s+= /)
      end # should not enable reporturl
    end

    context 'bad' do
      let(:params) { { :enc => false } }

      it { should raise_error(Puppet::Error, /expects a String/) }
    end

  end # reporturl

  ### run_in_noop ###

  context 'run_in_noop' do
    context 'on' do
      let(:params) { { 'run_in_noop' => true } }

      it 'set noop' do
        should contain_file('puppet.conf').
          with_content(/^\s*noop\s+= true$/)
      end # should not set noop
    end # on

    context 'off' do
      let(:params) { { 'run_in_noop' => false } }

      it 'not set noop' do
        should contain_file('puppet.conf').
          without_content(/^\s*noop\s+= true$/)
      end # should not set noop
    end

    context 'default' do
      it 'not set noop' do
        should contain_file('puppet.conf').
          without_content(/^\s*noop\s+= true$/)
      end # should not set noop
    end

    context 'bad' do
      let(:params) { { 'run_in_noop' => 'fish' } }

      it 'fail' do
        should raise_error(Puppet::Error, /expects a Boolean/)
      end # should fail
    end
  end # run_in_noop

  ### server ###

  context 'server' do
    context 'new server' do
      let(:params) { { :server => 'foo.bar' } }

      it 'have updated server' do
        should contain_file('puppet.conf').
          with_content(/^\s+server\s+= foo.bar$/)
      end # should have updated server
    end # new server

    context 'empty server or nothing from hiera' do
      let(:params) { { 'server' => '' } }

      it do
        should raise_error(Puppet::Error, /expects a String\[1/)
      end
    end # empty server or nothing from hiera

    context 'bad server type' do
      let(:params) { { :server => ['server.invalid'] } }

      it do
        should raise_error(Puppet::Error, /expects a String/)
      end
    end # bad server type
  end # server

  ### srv_domain ###

  context 'srv_domain' do
    context 'true' do
      let(:params) { { :server => 'foo.bar', :srv_domain => true } }

      it 'set srv_domain instead of server' do
        should contain_file('puppet.conf').
          with_content(/^\s+use_srv_records\s+= true$/).
          with_content(/^\s+srv_domain\s+= foo.bar$/).
          without_content(/^\s+server\s+= foo.bar$/)
      end
    end

    context 'false' do
      let(:params) { { :server => 'foo.bar', :srv_domain => false } }

      it 'set srv_domain instead of server' do
        should contain_file('puppet.conf').
          without_content(/^\s+use_srv_records\s+= true$/).
          without_content(/^\s+srv_domain\s+= foo.bar$/).
          with_content(/^\s+server\s+= foo.bar$/)
      end
    end

    context 'default' do
      let(:params) { { :server => 'foo.bar' } }

      it 'set srv_domain instead of server' do
        should contain_file('puppet.conf').
          without_content(/^\s+use_srv_records\s+= true$/).
          without_content(/^\s+srv_domain\s+= foo.bar$/).
          with_content(/^\s+server\s+= foo.bar$/)
      end
    end

    context 'bad' do
      let(:params) { { :server => 'foo.bar', :srv_domain => 'hi there' } }

      it 'fail' do
        should raise_error(Puppet::Error, /expects a Boolean/)
      end
    end
  end # srv_domain

  ### use_cache ###

  context 'use_cache' do
    context 'true' do
      let(:params) { { :use_cache => true } }

      it 'use the cache' do
        should contain_file('puppet.conf').
          without_content(/^\s+usecacheonfailure = false$/).
          with_content(/^\s+usecacheonfailure = true$/)
      end
    end

    context 'false' do
      let(:params) { { :use_cache => false } }

      it 'not use the cache' do
        should contain_file('puppet.conf').
          with_content(/^\s+usecacheonfailure = false$/).
          without_content(/^\s+usecacheonfailure = true$/)
      end
    end

    context 'default' do
      it 'not use the cache' do
        should contain_file('puppet.conf').
          with_content(/^\s+usecacheonfailure = false$/).
          without_content(/^\s+usecacheonfailure = true$/)
      end
    end

    context 'bad' do
      let(:params) { { :use_cache => 'hi there' } }

      it 'fail' do
        should raise_error(Puppet::Error, /expects a Boolean/)
      end
    end

  end # use_cache

  ### use_puppetdb ###

  context 'use_puppetdb' do
    context 'true' do
      let(:params) { { :master => true, :use_puppetdb => true } }

      it 'enable storeconfigs' do
        should contain_file('puppet.conf').
          with_content(/^\s+storeconfigs\s+= true$/).
          with_content(/^\s+storeconfigs_backend\s+= puppetdb$/)
      end # should enable storeconfigs
    end

    context 'false' do
      let(:params) { { :master => true, :use_puppetdb => false } }

      it 'not enable storeconfigs' do
        should contain_file('puppet.conf').
          without_content(/^\s+storeconfigs\s+= true$/).
          without_content(/^\s+storeconfigs_backend\s+= puppetdb$/)
      end # should not enable storeconfigs
    end

    context 'default' do
      let(:params) { { :master => true } }

      it 'not enable storeconfigs' do
        should contain_file('puppet.conf').
          without_content(/^\s+storeconfigs\s+= true$/).
          without_content(/^\s+storeconfigs_backend\s+= puppetdb$/)
      end # should not enable storeconfigs
    end

    context 'bad' do
      let(:params) { { 'use_puppetdb' => 'fish' } }

      it { should raise_error(Puppet::Error, /expects a Boolean/) }
    end
  end # use_puppetdb

end # puppet::config
