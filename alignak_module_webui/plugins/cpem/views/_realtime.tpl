<div clas="row">
    <div class="col-md-12 panel panel-default">
        <div class="panel-heading">

          <div class="pull-right">
            <span>Summary: </span>
            <span class="fa fa-calendar"></span> <span id="uptime" alt="Uptime">-</span></span>
            <span class="fa fa-dashboard"></span> <span id="dnbw" alt"Down Bandwidth">-</span>/<span id="upbw">-</span>
            <span class="fa fa-signal"></span> <span id="uprx" alt"Up Bandwidth">-</span>/<span id="dnrx">-</span>dbm
            <span class="fa fa-signal"></span> <span id="ccq">-</span>dbm
            <span class="fa fa-reorder"></span> <span id="service_ports"></span>
            <span>&nbsp;</span>
            <span class="btn btn-primary btn-xs" data-toggle="collapse" data-target="#info-panel">+</span>
          </div>

          <h4 class="panel-title">Realtime</h4>

        </div>

        <div class="panel-body">
          <div class="row">
            <div class="col-md-4">
              <div id="plot_bw" style="width: 100%; height: 120px;"></div>
            </div>

            <div class="col-md-4">
              <div id="plot_rx" style="width: 100%; height: 120px;"></div>
            </div>

            <div class="col-md-4">
              <div id="plot_ccq" style="width: 100%; height: 120px;"></div>
            </div>
          </div>
          <div class="row">
            <div class="col-md-6" id="docsisDownstreamTable"></div>
            <div class="col-md-6" id="docsisUpstreamTable"></div>
          </div>
        </div>

        <div id="info-panel" class="panel-body collapse">

        <div class="col-sm-4">
          <dl class="dl-horizontal">
            <dt>Serial Number</dt><dd>{{ cpe.customs.get('_SN', '').upper() }}</dd>
            %if cpe.customs.get('_DSN'):
            <dt>DSN</dt><dd>{{ cpe.customs.get('_DSN') }}</dd>
            %end
            %if cpe.customs.get('_MAC') and len(cpe.customs.get('_MAC')):
            <dt>MAC Address</dt><dd>{{cpe.customs.get('_MAC','00:00:00:00:00:00')}}</dd>
            %end
            %if cpe.customs.get('_MTAMAC') and len(cpe.customs.get('_MTAMAC')):
            <dt>MTA MAC</dt><dd>{{cpe.customs.get('_MTAMAC')}}</dd>
            %end
            <dt>CPE IP Address</dt><dd>{{cpe.cpe_address if hasattr(cpe, 'cpe_address') else '' }}</dd>
            <dt>CPE Router Address</dt><dd>{{cpe.cpe_router_address if hasattr(cpe, 'cpe_router_address') else '' }}</dd>
            <dt>CPE ATA Address</dt><dd>{{cpe.cpe_ata_address if hasattr(cpe, 'cpe_ata_address') else '' }}</dd>


            <dt>Registration host</dt><dd>{{ cpe.cpe_registration_host if hasattr(cpe, 'cpe_registration_host') else '' }}
                <a href="/all?search=type:host {{ cpe.cpe_registration_host if hasattr(cpe, 'cpe_registration_host') else '' }}"><i class="fa fa-search"></i></a></dd>
            <dt>Registration ID</dt><dd>{{cpe.cpe_registration_id if hasattr(cpe, 'cpe_registration_id') else '' }}
                <a href="/all?search=type:host {{ cpe.cpe_registration_host if hasattr(cpe, 'cpe_registration_host') else '' }}"><i class="fa fa-search"></i></a></dd>


            <dt>Registration tags</dt><dd>{{cpe.cpe_registration_tags if hasattr(cpe, 'cpe_registration_tags') else ''  }}</dd>
            <dt>Last status change</dt><dd><span id="last_state_change">Unknown</span></dd>
          </dl>
        </div>


        <div class="col-sm-4">
          <dl class="dl-horizontal">
            <dt>Configuration URL</dt>

        <dd>{{cpe.cpe_connection_request_url}}</dd>
            %if cpe.cpe_ipleases if hasattr(cpe, 'cpe_ipleases') else False:
            %try:
            %cpe_ipleases = ast.literal_eval(cpe.cpe_ipleases) or {'foo': 'bar'}
            %for ip,lease in cpe_ipleases.iteritems():
            %if app.proxy_sufix:
            <dt><a href="http://{{ip}}.{{app.proxy_sufix}}" target=_blank>{{ip}}</a></dt>
            %else:
            <dt>{{ip}}</dt>
            %end
            <dd>{{lease}}</dd>
            %end
            %except Exception, exc:
            <dt>{{cpe.cpe_ipleases}}</dt>
            <dd>{{exc}}</dd>
            %end
            %else:
            <dt>IP Leases</dt>
            %if app.proxy_sufix:
            <dt><a href="http://10.11.12.13.{{app.proxy_sufix}}" target=_blank>N/A</a></dt>
            %else:
            <dt>N/A</dt>
            %end
            %end

         <!--<button class="btn btn-default btn-xs center-block" data-toggle="collapse" data-target="#more-info">More</button>-->

       </dl>
     </div>
    <div>
    <div class="col-sm-4 dl-horizontal">
        <dl >
            <dt>Name</dt>
            <dd>{{cpe.customs.get('_CUSTOMER_NAME')}}</dd><dt>Surname</dt>
            <dd>{{cpe.customs.get('_CUSTOMER_SURNAME')}}</dd><dt>Address</dt>
            <dd>{{cpe.customs.get('_CUSTOMER_ADDRESS')}}</dd><dt>City</dt>
            <dd>{{cpe.customs.get('_CUSTOMER_CITY')}}</dd></dl>
        </dl>
    </div>

    </div>
    </div>

    </div>
</div>
