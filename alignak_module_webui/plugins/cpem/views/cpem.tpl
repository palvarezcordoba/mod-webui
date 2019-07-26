%breadcrumb = []

%title = 'cpe'

%js=['js/shinken.js', 'cpem/js/bootstrap-switch.min.js', 'cpem/js/datatables.min.js']
%css=['cpem/css/bootstrap-switch.min.css', 'cpem/css/datatables.min.css', 'cpem/css/vis.min.css', 'cpem/css/cpe.css']
%rebase("layout", js=js, css=css, breadcrumb=breadcrumb, title=title)

<script src="https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.1.2/handlebars.min.js"></script>

<script src="/static/cpem/js/krill.js"></script>
<script src="/static/cpem/js/jquery.flot.js" charset="utf-8"></script>
<script src="/static/cpem/js/plots.js" charset="utf-8"></script>
<script src="/static/cpem/js/vis.min.js" charset="utf-8"></script>
<script src="/static/cpem/js/datatables.min.js" charset="utf-8"></script>
<script src="/static/cpem/js/google-charts.min.js" charset="utf-8"></script>

<script>

// For old compatibility
var cpe = {}
var services = {}
var cpe_name = "";
var proxy_prefix = "";
var proxy_sufix = ".phicus.net"
var cpe_graphs = {} 

Handlebars.registerHelper( "when",function(operand_1, operator, operand_2, options) {
  var operators = {
   'eq': function(l,r) { return l == r; },
   'noteq': function(l,r) { return l != r; },
   'gt': function(l,r) { return Number(l) > Number(r); },
   'or': function(l,r) { return l || r; },
   'and': function(l,r) { return l && r; },
   '%': function(l,r) { return (l % r) === 0; }
  }
  , result = operators[operator](operand_1,operand_2);

  if (result) return options.fn(this);
  else  return options.inverse(this);
});


function update_cpe() {
    $.get( '/m/html/index.html', function( data ) {

        var templateScript = Handlebars.compile(data);
        var context = {
            location: window.location,
            poll: window.poll,
        }

        $.get('/api/cpesmetadata/' + window.cpe_realm + window.cpe_id + '?realm=' + window.cpe_realm, function( data ) {
            $.get("/api/potses/?cpe=" + window.cpe_id + '&realm=' + window.cpe_realm, function(potses) {
                data.potses = potses;
                context.cpe = data;
                context.ordered_actions = [
                    "unprovision",
                    "factory",
                    "reboot",
                    "reconfig",
                ];
                cpe = data;
                services = []

                data._services.forEach(function(element) {
                  services.push({
                    'name': element,
                    'state_id': 0,
                    'url': 'about:blank',
                    'content': '&nbsp;'
                  })
                });

                $.get('/api/customers/' + data.customer + '?realm=' + window.cpe_realm, function( data ) {
                    context.customer = data
                    $.get('/api/cpe_profiles/' + cpe.profile + '?realm=' + window.cpe_realm, function( data ) {
                        context.profile = data
                        html = templateScript(context);
                        $( ".content" ).html( html );
                        action_to_icon = {
                            unprovision: "reply",
                            factory: "fast-backward",
                            reboot: "refresh",
                            reconfig: "gears"
                        }
                        Object.keys(action_to_icon).forEach(k => $("#btn-" + k).children().addClass("fa-" + action_to_icon[k]))
                        loadPlots();
                        poll_cpe();
                        cpe_refresh();
                    })
                })


            });
        })
    });
}






function update_target() {
  var cpe_hash = window.location.hash.match(/(\w{3})(\d+)$/);
  var cpe_href  = window.location.href.match(/(\w{3})(\d+)$/);
  
  if ( cpe_hash ) {
    window.cpe_realm = cpe_hash[1];
    window.cpe_id   = cpe_hash[2];
  } else if( cpe_href ) {
    window.cpe_realm = cpe_href[1];
    window.cpe_id   = cpe_href[2];
  }

  //Old
  cpe_name = window.cpe_realm + window.cpe_id;

}

function poll_cpe() {
  //check_cpe_registration_host();



  $.getJSON('/api/kraken/info/' +  window.cpe_realm + window.cpe_id + '?realm=' + window.cpe_realm, function(data){
        window.poll = data;

        if ( typeof data.hostevent !== 'undefined' ) {
          $.each(data.hostevent, function(k,v){
              if ( typeof v.leased_address !== 'undefined' ) {
                alertify.log("New IP ADDRESS: " + v.leased_address, "info", 15000);
              }

          });
        }

        if(data && data.status) {

            data.status = data.status.replace(/\W+\s+/g, '').toUpperCase()

            $('#registration_state').html(data.status)
            $('#registration_state').next().remove()
            $('#upbw').html(humanBytes(data.upbw))
            $('#dnbw').html(humanBytes(data.dnbw))
            $('#dnrx').html(data.dnrx)
            $('#uprx').html(data.uprx)

            if (typeof data.ccq !== 'undefined') {
              $('#ccq').html(data.ccq + "%").show()
            }

            if (typeof data.catvrx !== 'undefined') {
              $('#ccq').html("CATV:" + data.catvrx + "").show()
            }

            if (typeof data.uptime === 'string') {
              d1 = Date.parse(data.uptime);
              //console.log(d1)
              d2 = Date.parse(new Date());
              //console.log(d2)
              delta = (d2 - d1) / 1000;
              $('#uptime').html(toHHMMSS(delta));
              if(delta > window.cpe_uptime) {
                window.cpe_uptime = delta;
              }
              $('#last_state_change').html( (new Date(d1)).toString() )
            }

            if (typeof data.uptime === 'number') {
              start = Date.parse(new Date()) - data.uptime;
              delta = data.uptime  /* / 1000 */
              if(delta > window.cpe_uptime) {
                window.cpe_uptime = delta;
              }
              $('#last_state_change').html( (new Date(start)).toString() )
            }



            if (typeof data.status_id !== "undefined") {
              $('#registration_state').css('color', Krill.getColorState(data.status_id) );
              $('#status2').html(getHTMLState(data.status_id));
            }


            //console.log(data);
            //enable or disable buttons

            if ( data.status_id == 0 ) {
              $('#btn-reboot')      .removeClass("disabled").prop("disabled", false);
              $('#btn-factrestore') .removeClass("disabled").prop("disabled", false);
              $('#btn-unprovision') .removeClass("disabled").prop("disabled", false);
              $('#btn-tr069')       .removeClass("disabled").prop("disabled", false);
            } else if ( data.status_id == 2 )  {
              $('#btn-reboot')      .addClass("disabled").prop("disabled", true);
              $('#btn-factrestore') .addClass("disabled").prop("disabled", true);
              $('#btn-tr069')       .addClass("disabled").prop("disabled", true);
              $('#btn-unprovision') .removeClass("disabled").prop("disabled", false);
            }

            if ( typeof data.cpe_registration_host === 'undefined' ) {
              $('#btn-reboot')     .addClass("disabled").prop("disabled", true);
              $('#btn-factrestore').addClass("disabled").prop("disabled", true);
              $('#btn-unprovision').addClass("disabled").prop("disabled", true);
              $('#btn-tr069')      .addClass("disabled").prop("disabled", true);
            } else {
              $('[data-type="registration-host"]').html(data.cpe_registration_host)
              $('[data-type="registration-id"]').html(data.cpe_registration_id)
            }


            if ( typeof data.lapse !== 'undefined' ) {
               CPE_POLL_UPDATE_FREQUENCY = Math.round( (data.lapse * 1000 ) * 1.20 );
               if ( CPE_POLL_UPDATE_FREQUENCY < 10000 ) {
                 CPE_POLL_UPDATE_FREQUENCY = 10000;
               }
            }

            if ( typeof data.ips !== 'undefined' ) {
               $("#ips").html('')
               $.each(data.ips, function(v,k){
                 $("#ips").append('<a href="http://'+proxy_prefix+k[1]+'.'+proxy_sufix+'">'+k[1]+'</a> | ');
               })
            }

            if (typeof data.service_ports !== "undefined") {
              line = ""
              $.each(data.service_ports, function(k,v){
                 line = line + v.service_vlan + '/'+ v.user_vlan
                 if ( typeof v.native_vlan !== 'undefined' && v.native_vlan ) {
                   line = line + "N";
                 }
                 line = line + " ";
              })
              $('#service_ports').html(line)
            }

            if (data.status && data.status != cpe.state) {
                cpe.state = data.status;
            }

            if (typeof data.perfdatas  !== 'undefined') {

              var downstreams = Krill.parsePerfdata(data.perfdatas.downstream);
              var upstreams   = Krill.parsePerfdata(data.perfdatas.upstream);
              var qoss        = Krill.parsePerfdata(data.perfdatas.qos);


              for (var i = 0; i < downstreams; i++) {
                if (downstreams[i][0] == 'dnrx') {
                  //data.dnrx = parseFloat(downstreams[i][1])
                  data.dnrx = Krill.parsePerfdata(downstreams[i])

                }
              }

              for (var i = 0; i < upstreams; i++) {
                if (upstreams[i][0] == 'uptx') {
                  data.uptx = Krill.parsePerfdata(upstreams[i][1])
                }
              }


              for (var i = 0; i < qoss; i++) {
                if (qoss[i][0] == 'dncorr') {
                  data.dncorr = Krill.parsePerfdata(upstreams[i][1])
                }
                if (qoss[i][0] == 'dnko') {
                  data.dnko = Krill.parsePerfdata(upstreams[i][1])
                }
              }


              qoss_table          = parsePerfdataTable2(qoss)
              qoss_table_titles   = Object.keys(qoss_table)
              qoss_table_rows     = Object.values(qoss_table)

              downstreams_table        = parsePerfdataTable2(downstreams)
              upstreams_table          = parsePerfdataTable2(upstreams)

              downstreams_table.dncorr = qoss_table.dncorr
              downstreams_table.dnko   = qoss_table.dnko
              upstreams_table.upcorr   = qoss_table.upcorr
              upstreams_table.upko     = qoss_table.upko

              downstreams_table_titles = Object.keys(downstreams_table)
              downstreams_table_rows   = Object.values(downstreams_table)

              upstreams_table_titles   = Object.keys(upstreams_table)
              upstreams_table_rows     = Object.values(upstreams_table)


              try {
                $('#docsisDownstreamTable').html(generatePerfTable(downstreams_table_titles, downstreams_table_rows));
                $('#docsisUpstreamTable').html(generatePerfTable(upstreams_table_titles, upstreams_table_rows));
              } catch(err) {
                console.log(err)
              }
              //$('#docsisQosTable').html(generatePerfTable(qoss_table_titles, qoss_table_rows));

            }


            updateGraphs(data);

        }

    });
}

// Actualizador servicios
function update_cpe_services() {
  $.ajax({
    url: '/cpe/quickservices/' + cpe_name,
    success: function(data) {
      var html = $('ul',data);
      $('li', html).on('click', function(){
         //console.log($(this).text());

         var _txt = $(this).clone().children().remove().end().text();
         _txt = _txt.split(":")
         _txt.shift()
         _txt = _txt.join(":")

         $('#search').val( _txt  );
      });
      $('#quickservices').html( $(html).html()
            .replace(/\$PROXY_SUFIX/g,proxy_sufix)
            .replace(/\$PROXY_PREFIX/g,proxy_prefix)
       );
    },
  });
}


$(function(){
  update_target();
  update_cpe();
  update_cpe_services();

  $(window).on('hashchange', function() {
    update_target();
    update_cpe();
    update_cpe_services();
  });

  if( typeof window.cpe_update_interval === 'undefined' ){
    window.cpe_update_interval = setInterval(function(){
      update_cpe();
    }, 600000);
  }

  if( typeof window.cpe_poll_interval === 'undefined' ){
    poll_cpe();
    window.cpe_poll_interval = setInterval(function(){
      poll_cpe();
    }, 10000);
  }

  if( typeof window.cpe_update_services_interval === 'undefined' ){
    window.cpe_update_services_interval = setInterval(function(){
      update_cpe_services();
    }, 5000);
  }

});

$(function () {
    disable_refresh();
});
</script>


