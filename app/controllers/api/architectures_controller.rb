#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Api::ArchitecturesController < Api::ForemanController

  @@foreman_api_resource = ForemanApi::Resources::Architecture

  def index
    api_call('index')
  end

  def show
    api_call('show', params['id'])
  end

  def create
    api_call('create', params.slice('architecture'))
  end

  def update
    api_call('update', params['id'], params.slice('architecture')) 
  end

  def destroy
    api_call('destroy', params['id'])
  end

end


