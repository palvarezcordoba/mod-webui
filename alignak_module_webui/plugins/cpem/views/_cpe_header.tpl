<div class="row">
    <div class="col-md-2">


        %if cpe.customs.get('_CPE_ID'):
            <div class="right" style="font-size: 24px"><a href="/host/{{ cpe.host_name }}">{{ cpe.host_name }}</a></div>
            <div class="right" style="font-size: 18px; ">{{cpe.customs.get('_CPE_MODEL')}}</div>
            %if cpe.customs.get('_SN') and len(cpe.customs.get('_SN')):
            <div title="{{ cpe.customs.get('_CPE_NOTES') }}" id="cpe-sn" style="cursor: pointer; text-align: right" class="font-fixed" style="font-size: 12px; text-align: right; color: #9E9E9E;">{{ cpe.customs.get('_SN', '') }}</div>
            %end

            %if cpe.customs.get('_MAC') and len(cpe.customs.get('_MAC')):
            <div title="{{ cpe.customs.get('_CPE_NOTES') }}" id="cpe-mac" style="cursor: pointer; text-align: right" class="font-fixed" style="font-size: 12px; text-align: right; color: #9E9E9E;">{{ cpe.customs.get('_MAC', '') }}</div>
            %end

            %if cpe.customs.get('_CPE_NOTES'):
            <div id="cpe-notes" style="cursor: pointer; text-align: right" class="font-fixed" style="font-size: 12px; text-align: right; color: #9E9E9E;">{{ cpe.customs.get('_CPE_NOTES') }}</div>
            %end

        %else:
            <div class="right" style="font-size: 24px">
              <a href="/host/{{ cpe.host_name }}">{{ cpe.host_name }}</a>




            </div>
            <div class="right" style="font-size: 22px; "><a href="{{ cpe_proxy_url }}" target=_blank>{{ cpe.address }}</a></div>
            %if cpe.customs.get('_MAC') and len(cpe.customs.get('_MAC')):
            <div title="{{ cpe.customs.get('_CPE_NOTES') }}" id="cpe-mac" style="cursor: pointer; text-align: right" class="font-fixed" style="font-size: 12px; text-align: right; color: #9E9E9E;">{{ cpe.customs.get('_MAC', '') }}</div>
            %end
        %end
    </div>

    <div class="col-md-6" style="border-left: 1px solid gray">
        %if cpe.customs.get('_CPE_ID'):
        <div style="font-size: 22px">{{ cpe.customs.get('_CUSTOMER_NAME')}} {{cpe.customs.get('_CUSTOMER_SURNAME')}}</div>
        <div style="font-size: 18px; color: #666; white-space:normal;">
            <a href="/cpe/{{ cpe.cpe_registration_host }}" data-type="registration-host">{{ cpe.cpe_registration_host }}</a><span><span data-type="registration-host-state"></span><span>/</span><a href="/all?search=type:host {{cpe.cpe_registration_id}}" data-type="registration-id">{{ cpe.cpe_registration_id }}</a><span>:</span><span id="registration_state"><i class="fa fa-spinner fa-spin"></i> <!--{{cpe.cpe_registration_state}}--></span>
        </div>
        <div style="font-size: 18px; color: #999;">
            %if cpe.customs.get('_ACTIVE') == '1':
            <span style="color: #64DD17" alt="Enabled Internet access" title="CPE Enabled"><i class="fa fa-thumbs-up"></i></span>
                %if cpe.customs.get('_ACCESS') == '1':
                <span style="color: #64DD17" alt="Enabled Internet access" title="Enabled Internet access"><i class="fa fa-globe"></i><!--Internet access--></span>
                %else:
                <span style="color: #E65100" alt="Disabled Internet access" title="Disabled Internet access"><i class="fa fa-globe text-danger"></i><!--Disabled Internet access--></span>
                %end
            %else:
            <span style="color: #E65100" alt="Disabled Internet access" title="CPE disabled"><i class="fa fa-thumbs-down text-danger"></i><!--Disabled Internet access--></span>
            %end

            %tv_profile = str(cpe.customs.get('_TV_PROFILE') if hasattr(cpe,'customs') else "")
            %if 'catv' in tv_profile:
            <span style="color: green" alt="Enabled CATV" title="Enabled CATV"><i class="fa fa-tv"></i><!--Internet access--></span>
            %end
            %if 'iptv' in tv_profile:
            <span style="color: blue" alt="Enabled IPTV" title="Enabled IPTV"><i class="fa fa-tv"></i><!--Internet access--></span>
            %end

            <span style="color: #9E9E9E"><i class="fa fa-arrow-circle-o-down"></i>{{cpe.customs.get('_DOWNSTREAM')}}</span>
            <span style="color: #9E9E9E"><i class="fa fa-arrow-circle-o-up"></i>{{cpe.customs.get('_UPSTREAM')}}</span>

            %if cpe.customs.get('_VOICE1_CLI'):
             | <span style="color: #607D8B">1<i class="fa fa-phone" aria-hidden="true"></i> {{ cpe.customs.get('_VOICE1_CLI') }}</span>
            %end
            %if cpe.customs.get('_VOICE2_CLI'):
             | <span style="color: #607D8B">2<i class="fa fa-phone" aria-hidden="true"></i> {{ cpe.customs.get('_VOICE2_CLI') }}</span>
            %end
        </div>
        <div style="font-size: 18px; color: #333;" id="ips">
          %if hasattr(cpe, 'cpe_address') and cpe.cpe_address:
          <a target="_blank" href="http://{{ '' + cpe.cpe_address + '.' + app.proxy_sufix }}">{{ cpe.cpe_address }}</a>
          %end
        </div>
        %else:
          <span></span>
        %end
    </div>

    <div class="col-md-4">
        <div class="btn-group pull-right" role="group">
            %vendor = str(cpe.customs.get('_VENDOR') if hasattr(cpe,'customs') else "")

            %if 'Mikrotik' in vendor:

            %winbox_port = ""
            %winbox_address = cpe.address
            %winbox_username = ""
            %winbox_password = ""

            %if hasattr(cpe,'customs') and cpe.customs.get('_MIKROTIK_WINBOX_PORT'):
            %winbox_port = "%s" % cpe.customs.get('_MIKROTIK_WINBOX_PORT')
            %end

            %if hasattr(cpe,'customs') and cpe.customs.get('_PUBLIC_ADDRESS'):
            %winbox_address = cpe.customs.get('_PUBLIC_ADDRESS')
            %end

            <button onclick="top.location.href='winbox://{{ winbox_username}}{{ winbox_password }}{{ winbox_address }}{{ winbox_port }}';" id="btn-winbox" type="button" class="btn btn-default"><i class="fa fa-gears" aria-hidden="true"></i>&nbsp; Winbox</button>
            %end

            %tech = str(cpe.customs.get('_TECH') if hasattr(cpe,'customs') else cpe.tech)

            %if True and tech in ('wifi'):
            <button id="btn-update" type="button" class="btn btn-default"><i class="fa fa-arrow-up" aria-hidden="true"></i>&nbsp; Update</button>
            <a href="/cpe/{{ cpe.host_name }}/backup" id="btn-backup" type="button" class="btn btn-default"><i class="fa fa-save" aria-hidden="true"></i>&nbsp; Backup</a>
            %end

            %if cpe.customs.get('_CPE_MODEL') in ('UBNTM5','TL-WR841ND'):
            %cpe_webport = cpe.customs.get('_CPE_WEBPORT',7125)
            %cpe_router_webport = cpe.customs.get('_CPE_ROUTER_WEBPORT',1025)
            
            %cpe_address        = cpe.cpe_address if hasattr(cpe, 'cpe_address') else ''
            %cpe_router_address = cpe.cpe_router_address if hasattr(cpe, 'cpe_router_address') else cpe_address

            <a href="http://{{ '' + cpe_address + '-' + str(cpe_webport) + '.' + app.proxy_sufix }}" target="_blank" id="btn-web1" type="button" class="btn btn-default {{'disabled' if not cpe_address else '' }}"><i class="fa fa-globe" aria-hidden="true"></i>&nbsp; CPE</a>
            <a href="http://{{ '' + cpe_router_address + '-' + str(cpe_router_webport) + '.' + app.proxy_sufix }}" target="_blank" id="btn-web2" type="button" class="btn btn-default {{'disabled' if not cpe_router_address else '' }}"><i class="fa fa-globe" aria-hidden="true"></i>&nbsp; Router</a>
            %end

            %if tech in ('gpon'):
            <button id="btn-unprovision" type="button" class="btn btn-default" {{'disabled' if not reboot_available else ''}} ><i class="fa fa-reply" aria-hidden="true"></i>&nbsp; Unprovision</button>
            <button id="btn-factrestore" type="button" class="btn btn-default" {{'disabled' if not reboot_available else ''}} ><i class="fa fa-fast-backward" aria-hidden="true"></i>&nbsp; Factory</button>
            %end
            %if tech in ('gpon', 'docsis'):
            <button id="btn-reboot" type="button" class="btn btn-default" {{'disabled' if not reboot_available else ''}} ><i class="fa fa-refresh" aria-hidden="true"></i>&nbsp; Reboot</button>
            %end
            %if hasattr(cpe, 'cpe_connection_request_url'):
            <button id="btn-tr069" type="button" class="btn btn-default" {{'disabled' if not tr069_available else  ''}} ><i class="fa fa-gears" aria-hidden="true"></i>&nbsp; Reconfig</button>
            %end


            %if hasattr(cpe,'customs') and cpe.customs.get('_MODE') == 'ap':
            <a href="{{ cpe_proxy_url }}"><span  id="btn-web" type="button" class="btn btn-default" ><i class="fa fa-gears" aria-hidden="true"></i>&nbsp; Web</span></a>
            %end

        </div>
    </div>


</div>
