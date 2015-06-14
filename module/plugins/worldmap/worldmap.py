#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright (C) 2009-2012:
#    Gabes Jean, naparuba@gmail.com
#    Mohier Frédéric frederic.mohier@gmail.com
#    Karfusehr Andreas, frescha@unitedseed.de
# This file is part of Shinken.
#
# Shinken is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Shinken is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Shinken.  If not, see <http://www.gnu.org/licenses/>.

import time

from shinken.log import logger
from shinken.misc.filter import only_related_to

try:
    import json
except ImportError:
    # For old Python version, load
    # simple json (it can be hard json?! It's 2 functions guy!)
    try:
        import simplejson as json
    except ImportError:
        print "Error: you need the json or simplejson module"
        raise

### Will be populated by the UI with it's own value
app = None

### Plugin's parameters
params = {}


# Hook called by WebUI module once the plugin is loaded ...
def load_config(app):
    global params

    logger.info("[WebUI-worldmap] loading configuration ...")
    
    default_position = app.get_common_preference('worldmap-default_position', '')
    if default_position == '':
        app.set_common_preference('worldmap-default_position', '{"default_zoom": 16, "default_Lng": 5.080625, "default_Lat": 45.054148}')
        default_position = app.get_common_preference('worldmap-default_position', '')
    params.update(json.loads(default_position))
    
    hosts = app.get_common_preference('worldmap-hosts', '')
    if hosts == '':
        app.set_common_preference('worldmap-hosts', '{"hosts_level": [1,2,3,4,5]}')
        hosts = app.get_common_preference('worldmap-hosts', '')
    params.update(json.loads(hosts))
    
    services = app.get_common_preference('worldmap-services', '')
    if services == '':
        app.set_common_preference('worldmap-services', '{"services_level": [1,2,3,4,5]}')
        services = app.get_common_preference('worldmap-services', '')
    params.update(json.loads(services))
    
    layer = app.get_common_preference('worldmap-layer', '')
    if layer == '':
        app.set_common_preference('worldmap-layer', '{"layer": ""}')
        layer = app.get_common_preference('worldmap-layer', '')
    params.update(json.loads(layer))

    logger.info("[WebUI-worldmap] configuration loaded.")
    logger.info("[WebUI-worldmap] configuration, params: %s", params)

# Our page. If the user call /worldmap
def show_worldmap():
    user = app.check_user_authentication()

    # We are looking for hosts with valid GPS coordinates,
    # and we just give them to the template to print them.
    valid_hosts = []
    for h in app.get_hosts(user):
        logger.debug("[WebUI-worldmap] found host '%s'", h.get_name())
        
        # Filter hosts
        # if h.get_name() in params['map_hostsHide']:
            # continue
            
        # if h.get_name() not in params['map_hostsShow'] and h.business_impact not in params['map_hostsLevel']:
            # continue
        
        if h.business_impact not in params['hosts_level']:
            continue
        
        _lat = h.customs.get('_LOC_LAT', params['default_Lat'])
        _lng = h.customs.get('_LOC_LNG', params['default_Lng'])

        if _lat and _lng:
            try:
                # Maybe the customs are set, but with invalid float?
                _lat = float(_lat)
                _lng = float(_lng)
            except ValueError:
                logger.debug("[WebUI-worldmap] host '%s' has invalid GPS coordinates (not float)", h.get_name())
                continue
                
            # Look for good range, lat/long must be between -180/180
            if -180 <= _lat <= 180 and -180 <= _lng <= 180:
                logger.debug("[WebUI-worldmap] host '%s' located on worldmap: %f - %f", h.get_name(), _lat, _lng)
                valid_hosts.append(h)

    # So now we can just send the valid hosts to the template
    return {'app': app, 'user': user, 'params': params, 'hosts': valid_hosts}


def show_worldmap_widget():
    user = check_user_authentication()

    wid = app.request.GET.get('wid', 'widget_worldmap_' + str(int(time.time())))
    collapsed = (app.request.GET.get('collapsed', 'False') == 'True')

    options = {}

    # We are looking for hosts that got valid GPS coordinates,
    # and we just give them to the template to print them.
    valid_hosts = []
    for h in app.get_hosts(user):
        # Filter hosts
        # if h.get_name() in params['map_hostsHide']:
            # continue
            
        # if h.get_name() not in params['map_hostsShow'] and h.business_impact not in params['map_hostsLevel']:
            # continue
        
        if h.business_impact not in params['hosts_level']:
            continue
        
        _lat = h.customs.get('_LOC_LAT', params['default_Lat'])
        _lng = h.customs.get('_LOC_LNG', params['default_Lng'])

        if _lat and _lng:
            try:
                # Maybe the customs are set, but with invalid float?
                _lat = float(_lat)
                _lng = float(_lng)
            except ValueError:
                logger.debug("[WebUI-worldmap] host '%s' has invalid GPS coordinates (not float)", h.get_name())
                continue
            # Look for good range, lat/long must be between -180/180
            if -180 <= _lat <= 180 and -180 <= _lng <= 180:
                valid_hosts.append(h)

    return {'app': app, 'user': user, 'wid': wid,
            'collapsed': collapsed, 'options': options,
            'base_url': '/widget/worldmap', 'title': 'Worldmap',
            'params': params, 'hosts' : valid_hosts
            }


widget_desc = '''<h4>Worldmap</h4>
Show a map of all monitored hosts.
'''

# We export our properties to the webui
pages = {
    show_worldmap: {'routes': ['/worldmap'], 'view': 'worldmap', 'static': True},
    show_worldmap_widget: {'routes': ['/widget/worldmap'], 'view': 'worldmap_widget', 'static': True, 'widget': ['dashboard'], 'widget_desc': widget_desc, 'widget_name': 'worldmap', 'widget_picture': '/static/worldmap/img/widget_worldmap.png'},
}
