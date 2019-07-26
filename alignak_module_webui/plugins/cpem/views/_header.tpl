<div class="row">
    <div class="col-md-6">
        <div class="right" style="font-size: 24px">
          <a href="/host/{{ cpe.host_name }}">{{ cpe.host_name }}</a>
        </div>
        <div class="right" style="font-size: 22px; "><a href="{{ cpe_proxy_url }}" target=_blank>{{ cpe.address }}</a></div>
        %if cpe.customs.get('_MAC') and len(cpe.customs.get('_MAC')):
        <div title="{{ cpe.customs.get('_CPE_NOTES') }}" id="cpe-mac" style="cursor: pointer; text-align: right" class="font-fixed" style="font-size: 12px; text-align: right; color: #9E9E9E;">{{ cpe.customs.get('_MAC', '') }}</div>
        %end
    </div>

    <div class="col-md-2" style="border-left: 1px solid gray">

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




            <a href="{{ cpe_proxy_url }}">
              <span  id="btn-web" type="button" class="btn btn-default" >
                <i class="fa fa-gears" aria-hidden="true"></i>&nbsp; Web
              </span>
            </a>

            <span class="dropdown">
              <a href="/host/{{ cpe.host_name }}" class="btn btn-default" id="dropdownMenu1" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
                <i class="fa fa-gears" aria-hidden="true"></i>&nbsp; More <span class="caret"></span>
              </a>

              <ul class="dropdown-menu" aria-labelledby="dropdownMenu1">
                <li><a href="/host/{{ cpe.host_name }}">Info</a></li>
                <li><a href="/host/{{ cpe.host_name }}#graphs">Graphs</a></li>
                <li><a href="/trivial?search={{ cpe.host_name }}">Trivial</a></li>
              </ul>
            </span>

        </div>
    </div>


</div>
