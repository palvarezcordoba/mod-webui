<div class="row container-fluid clearfix">
    %if app.logs_module.is_available():
    <div class="col-md-6 panel panel-default">
        <div class="panel-heading">
          <div class="pull-right">
            <a class="btn btn-primary btn-xs" data-toggle="collapse" href="#logHistory">+</a>
          </div>
          <h4 class="panel-title">Log History</h4>
        </div>
        <div id="logHistory" class="panel-body panel-collapse collapse">
            <table id="inner_history" class="table" data-element='{{ cpe.get_full_name() if hasattr(cpe, "get_full_name") else '' }}'>
                <thead>
                    <tr>
                        <th>State</th>
                        <th>Time</th>
                        <th>Service</th>
                        <th>Message</th>
                    </tr>
                </thead>
            </table>
        </div>
    </div>
    <div class="col-md-6 panel panel-default">
        <div class="panel-heading">
          <div class="pull-right">
            <a class="btn btn-primary btn-xs" data-toggle="collapse" href="#eventHistory">+</a>
          </div>
          <h4 class="panel-title">Event History</h4>
        </div>
        <div id="eventHistory" class="panel-body panel-collapse collapse">
            <table id="inner_events" class="table" data-element='{{ cpe.get_full_name() if hasattr(cpe, "get_full_name") else '' }}'>
                <thead>
                    <tr>
                        <th>Time</th>
                        <th>Source</th>
                        <th>Message</th>
                    </tr>
                </thead>
            </table>
        </div>
    </div>
    %end
</div>
