require 'spec_helper'
describe 'mariadb' do
  context 'with default values for all parameters' do
    it { should contain_class('mariadb') }
  end
end
