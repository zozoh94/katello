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

require 'util/search'

class Pool < ActiveRecord::Base
  include Glue::Candlepin::Pool

  set_table_name "pools"
  has_many :key_pools, :foreign_key => "pool_id", :dependent => :destroy
  has_many :activation_keys, :through => :key_pools

  # ActivationKey includes the Pool's json in its own'
  def as_json(*args)
    {:cp_id => self.cp_id}
  end

  # Most ActiveRecord models that need to be indexed do so through including IndexedModel. Since not all Pool
  # objects are persisted, this could lead to confusion and unnecessary overhead. (Only Pools referenced by
  # ActivationKeys are stored.) The methods below are the infrastructure for indexing the Pool objects.
  def self.display_attributes
    ['name', 'sla', 'start', 'end', 'consumed', 'product', 'account', 'contract', 'virtual']
  end

  def index_options
    {
      "_type"     => :pool,
      "id"        => @cp_id,
      "name"      => @product_name,
      "name_sort" => @product_name,
      "product_name"=> @product_name,
      "start"     => @start_date,
      "end"       => @end_date,
      "product"   => @product_id,
      "product_id"=> @product_id,
      "account"   => @account_number,
      "contract"  => @contract_number,
      "sla"       => @support_level,
      "support_level"=> @support_level,
      "virtual"   => @virt_only,
      "org"       => @owner["key"],
      "consumed"  => @consumed,
      "quantity"  => @quantity,
      "pool_derived" => @pool_derived,
      "derived"   => @pool_derived,
      "provider_id"=> provider_id,
      "stacking_id" => @stacking_id,
      "multi_entitlement" => @multi_entitlement
    }
  end

  def self.index_mapping
    {
      :pool => {
        :properties => {
          :name         => {:type=>'string', :analyzer=>:kt_name_analyzer},
          :name_sort    => {:type=>'string', :index=>:not_analyzed},
          :product_name => {:type=>'string', :index=>:not_analyzed},
          :all          => {:type=>'string'},
          :begin        => {:type=>'date'},
          :end          => {:type=>'date'},
          :sockets      => {:type=>'long'},
          :sla          => {:type=>'string'},
          :support_level=> {:type=>'string', :index=>:not_analyzed},
          :org          => {:type=>'string', :index=>:not_analyzed},
          :quantity     => {:type=>'long'},
          :consumed     => {:type=>'long'},
          :pool_derived => {:type=>'boolean', :index=>:not_analyzed},
          :derived      => {:type=>'boolean'},
          :provider_id  => {:type=>'long', :index=>:not_analyzed},
          :stacking_id  => {:type=>'string'},
          :multi_entitlement => {:type=>'boolean'}
        }
      }
    }
  end

  def self.index_settings
    {
        "index" => {
            "analysis" => {
                "filter" => Katello::Search::custom_filters,
                "analyzer" => Katello::Search::custom_analyzers
            }
        }
    }
  end

  def self.index
    "#{AppConfig.elastic_index}_pool"
  end

  # If the pool_json is passed in, then candlepin is not hit again to fetch it. This is for the case where
  # prior to this call the pool was already fetched.
  def self.find_pool(cp_id, pool_json=nil)
    pool_json = Resources::Candlepin::Pool.find(cp_id) if !pool_json
    ::Pool.new(pool_json) if not pool_json.nil?
  end

  def self.index_pools pools
    json_pools = pools.collect{ |pool|
      pool.as_json.merge(pool.index_options)
    }
    Tire.index self.index do
      create :settings => ::Pool.index_settings, :mappings => ::Pool.index_mapping
      import json_pools
    end if !json_pools.empty?
  end

  def self.search query, start, page_size, filters={}, sort=[:name_sort, "ASC"]
    return [] if !Tire.index(self.index).exists?

    all_rows = query.blank? #if blank, get all rows

    search = Tire.search self.index do
      query do
        if all_rows
          all
        else
          # No default_field is specified to let search span all indexed fields
          string query, {}
        end
      end

      if page_size > 0
       size page_size
       from start
      end

      if filters.has_key?(:org)
        filter :term, :org=>filters[:org]
      end
      if filters.has_key?(:provider_id)
        filter :term, :provider_id=>filters[:provider_id]
      end

      sort { by sort[0], sort[1] } unless !all_rows
    end
    return search.results
  rescue
    return []
  end

  # Some fields are are not native to the Candlepin object but are useful for searching
  def provider_id
    @cp_provider_id
  end
  def provider_id= cp_id
    @cp_provider_id = cp_id
  end


end
