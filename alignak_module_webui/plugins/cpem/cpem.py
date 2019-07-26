#!/usr/bin/python

# -*- coding: utf-8 -*-

import os
from functools import partial

import bottle
from alignak.log import logger

webuimod_dir = os.path.abspath(os.path.dirname(__file__))


def show_m(host):
    return {}


def show_m_hash():
    return {}


def load_html(path):
    static_folder = os.path.join(webuimod_dir, 'htdocs/html')

    logger.info("[WebUi-m] p=%s", static_folder)

    p = os.path.join(static_folder, path)
    if not os.path.exists(p):
        app.redirect404()

    return bottle.static_file(path, root=static_folder)


import time

import yaml
from libkrill.config import Config as KrillConfig
from libkrill.kws.datamanager import KwsDataManager

# Will be populated by the UI with it's own value
app = None


# Our page
def show_cpe(cpe_name):
    kc = KrillConfig('/etc/krill')
    datamanager = KwsDataManager(kc.kws_list or [])

    cpe = None
    parent = None

    ''' Mostrar la ficha del CPE con nombre cpe_name.'''
    # Ok, we can lookup it
    user = app.bottle.request.environ['USER']

    # if not cpe_name.startswith('cpe'):
    # app.redirect404()

    cpe = app.datamgr.get_host(cpe_name, user)  # or app.redirect404()

    try:
        if not cpe:
            cpe = datamanager.get_cpehost_by_hostname(cpe_name)
    except:
        app.redirect404()

    if hasattr(cpe, 'cpe_registration_host'):
        parent = app.datamgr.get_host(cpe.cpe_registration_host, user)

    # Set hostgroups level ...
    app.datamgr.set_hostgroups_level(user)

    # Get graph data. By default, show last 4 hours
    maxtime = int(time.time())
    mintime = maxtime - 7 * 24 * 3600

    try:
        with open("/etc/krill/cpe_models.yml", 'r') as stream:
            models = yaml.load(stream)
    except:
        pass

    models = {}
    model = {}
    if '_CPE_MODEL' in cpe.customs:
        _model = cpe.customs.get('_CPE_MODEL')
        if _model and _model in models:
            model.update(models.get(_model))

    return {'cpe': cpe, 'parent': parent, 'mintime': mintime, 'maxtime': maxtime, 'model': model}


def show_quick_services(cpe_name):
    cpe = None
    parent = None

    ''' Mostrar la ficha del CPE con nombre cpe_name.'''
    # Ok, we can lookup it
    user = app.bottle.request.environ['USER']

    # if not cpe_name.startswith('cpe'):
    # app.redirect404()

    cpe = app.datamgr.get_host(cpe_name, user) or app.redirect404()

    if cpe.customs.get("cpe_registration_host"):
        parent = app.datamgr.get_host(cpe.cpe_registration_host, user)

    # Set hostgroups level ...
    app.datamgr.set_hostgroups_level(user)

    # Get graph data. By default, show last 4 hours
    maxtime = int(time.time())
    mintime = maxtime - 7 * 24 * 3600

    return {'cpe': cpe, 'parent': parent, 'mintime': mintime, 'maxtime': maxtime}


def show_quick(cpe_name):
    ''' Mostrar la ficha del CPE con nombre cpe_name.'''
    # Ok, we can lookup it
    user = app.bottle.request.environ['USER']
    host = app.datamgr.get_host(cpe_name, user) or app.redirect404()

    # worst service
    worst_service_id = 0

    data = {
        'state': host.state,
        'state_id': host.state_id,
        'worst_state_id': max(s.state_id for s in host.services if s.state_id < 3)
    }

    return data


def backup(cpe_name):
    ''' Mostrar la ficha del CPE con nombre cpe_name.'''
    # Ok, we can lookup it
    user = app.bottle.request.environ['USER']
    host = app.datamgr.get_host(cpe_name, user) or app.redirect404()

    return "toma caracola"


pages = {
    show_m: {
        'name': 'Cpe', 'route': '/cpe/:host', 'view': 'cpem', 'static': True,
    },

    show_m_hash: {
        'name': 'Cpe', 'route': '/cpe/', 'view': 'cpem', 'static': True,
    },

    load_html: {
        'name': 'Static', 'route': '/m/html/:path#.+#',
    },

    show_quick: {
        'name': 'Quick', 'route': '/cpe/quick/:cpe_name',
    },

    show_quick_services: {
        'name': 'QuickServices', 'route': '/cpe/quickservices/:cpe_name', 'view': 'quickservices', 'static': True,
    },

    backup: {
        'name': 'Backup', 'route': '/cpe/:cpe_name/backup',
    }

}
