require 'spec_helper'

describe 'elasticsearch::user' do
  let(:title) { 'elastic' }

  let(:pre_condition) do
    <<-EOS
      class { 'elasticsearch': }
    EOS
  end

  on_supported_os(
    :hardwaremodels => ['x86_64'],
    :supported_os => [
      {
        'operatingsystem' => 'CentOS',
        'operatingsystemrelease' => ['7']
      }
    ]
  ).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts.merge(
        :scenario => '',
        :common => ''
      ) }

      context 'with default parameters' do
        let(:params) do
          {
            :password => 'foobar',
            :roles => %w[monitor user]
          }
        end

        it { should contain_elasticsearch__user('elastic') }
        it { should contain_elasticsearch_user('elastic') }
        it do
          should contain_elasticsearch_user_roles('elastic').with(
            'ensure' => 'present',
            'roles'  => %w[monitor user]
          )
        end
      end

      describe 'collector ordering' do
        describe 'when present' do
          let(:pre_condition) do
            <<-EOS
              class { 'elasticsearch': }
              elasticsearch::template { 'foo': content => {"foo" => "bar"} }
              elasticsearch::role { 'test_role':
                privileges => {
                  'cluster' => 'monitor',
                  'indices' => {
                    '*' => 'all',
                  },
                },
              }
            EOS
          end

          let(:params) do
            {
              :password => 'foobar',
              :roles => %w[monitor user]
            }
          end

          it { should contain_elasticsearch__role('test_role') }
          it { should contain_elasticsearch_role('test_role') }
          it { should contain_elasticsearch_role_mapping('test_role') }
          it { should contain_elasticsearch__user('elastic')
            .that_comes_before([
            'Elasticsearch::Template[foo]'
          ]).that_requires([
            'Elasticsearch::Role[test_role]'
          ])}

          include_examples 'class', :systemd
        end

        describe 'when absent' do
          let(:pre_condition) do
            <<-EOS
              class { 'elasticsearch': }
              elasticsearch::template { 'foo': content => {"foo" => "bar"} }
              elasticsearch::role { 'test_role':
                privileges => {
                  'cluster' => 'monitor',
                  'indices' => {
                    '*' => 'all',
                  },
                },
              }
            EOS
          end

          let(:params) do
            {
              :password => 'foobar',
              :roles => %w[monitor user]
            }
          end

          it { should contain_elasticsearch__role('test_role') }
          it { should contain_elasticsearch_role('test_role') }
          it { should contain_elasticsearch_role_mapping('test_role') }
          it { should contain_elasticsearch__user('elastic')
            .that_comes_before([
              'Elasticsearch::Template[foo]'
          ]).that_requires([
            'Elasticsearch::Role[test_role]'
          ])}

          include_examples 'class', :systemd
        end
      end
    end
  end
end
