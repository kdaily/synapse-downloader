import os
import getpass
import synapseclient as syn
import synapseutils
import logging
from datetime import datetime


class SynapseDownloaderSync:
    """Use synapseutils.sync.syncFromSynapse to do recursive download.

    """

    def __init__(self, starting_entity_id, download_path, username=None, password=None):
        self._synapse_client = None
        self._starting_entity_id = starting_entity_id
        self._username = username
        self._password = password

        self.start_time = None
        self.end_time = None

        var_path = os.path.expandvars(download_path)
        expanded_path = os.path.expanduser(var_path)
        self._download_path = expanded_path
        self.ensure_dirs(self._download_path)

    def synapse_login(self):
        print('Logging into Synapse...')
        self._username = self._username or os.getenv('SYNAPSE_USERNAME')
        self._password = self._password or os.getenv('SYNAPSE_PASSWORD')

        if not self._username:
            self._username = input('Synapse username: ')

        if not self._password:
            self._password = getpass.getpass(prompt='Synapse password: ')

        try:
            self._synapse_client = syn.Synapse(skip_checks=True)
            self._synapse_client.login(self._username, self._password, silent=True)
        except Exception as ex:
            self._synapse_client = None
            print('Synapse login failed: {0}'.format(str(ex)))

        return self._synapse_client is not None

    def ensure_dirs(self, local_path):
        if not os.path.isdir(local_path):
            os.makedirs(local_path)

    def execute(self):
        self.synapse_login()
        parent = self._synapse_client.get(self._starting_entity_id, downloadFile=False)
        if type(parent) not in [syn.Project, syn.Folder]:
            raise Exception('Starting entity must be a Project or Folder.')
        print('Starting entity: {0} ({1})'.format(parent.name, parent.id))
        print('Downloading to: {0}'.format(self._download_path))
        print('')

        self.start_time = datetime.now()
        synapseutils.sync.syncFromSynapse(syn=self._synapse_client,
                                          entity=parent,
                                          path=self._download_path,
                                          ifcollision='overwrite.local')
        self.end_time = datetime.now()
        
        print('')
        print('Run time: {0}'.format(self.end_time - self.start_time))
