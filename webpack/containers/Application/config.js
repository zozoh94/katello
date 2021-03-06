import Repos from '../../scenes/RedHatRepositories';
import Subscriptions from '../../scenes/Subscriptions';
import UpstreamSubscriptions from '../../scenes/Subscriptions/UpstreamSubscriptions/index';
import SubscriptionDetails from '../../scenes/Subscriptions/Details';
import SetOrganization from '../../components/SelectOrg/SetOrganization';
import WithOrganization from '../../components/WithOrganization/withOrganization';
import ModuleStreams from '../../scenes/ModuleStreams';
import withHeader from './withHeaders';

// eslint-disable-next-line import/prefer-default-export
export const links = [
  {
    path: 'redhat_repositories',
    component: WithOrganization(
      withHeader(Repos, { title: __('RH Repos') }),
      '/redhat_repositories',
    ),
  },
  {
    path: 'subscriptions',
    component: WithOrganization(
      withHeader(Subscriptions, { title: __('RH Subscriptions') }),
      '/subscriptions',
    ),
  },
  {
    path: 'subscriptions/add',
    component: withHeader(UpstreamSubscriptions, { title: __('Add Subscriptions') }),
  },
  {
    // eslint-disable-next-line no-useless-escape
    path: 'subscriptions/:id([0-9]*$)',
    component: withHeader(SubscriptionDetails, { title: __('Subscription Details') }),
  },
  {
    path: 'organization_select',
    component: SetOrganization,
  },
  {
    text: 'Module Streams',
    path: 'module_streams',
    component: ModuleStreams,
  },
];
