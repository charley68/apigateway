resource "aws_api_gateway_rest_api" "url-shortener-api" {

  name = "url-shortener-api2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# ADMIN METHOD

resource "aws_api_gateway_resource" "admin" {
  rest_api_id = aws_api_gateway_rest_api.url-shortener-api.id
  parent_id   = aws_api_gateway_rest_api.url-shortener-api.root_resource_id
  path_part   = "admin"
}

resource "aws_api_gateway_method" "admin-get" {
  rest_api_id   = aws_api_gateway_rest_api.url-shortener-api.id
  resource_id   = aws_api_gateway_resource.admin.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "admin_response_200" {

  depends_on = [ aws_api_gateway_method.admin-get ]
  rest_api_id   = aws_api_gateway_rest_api.url-shortener-api.id
  resource_id   = aws_api_gateway_resource.admin.id
  http_method   = "GET"
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type"     = false
  }
}

resource "aws_api_gateway_integration" "admin_integration" {
  rest_api_id          = aws_api_gateway_rest_api.url-shortener-api.id
  resource_id          = aws_api_gateway_resource.admin.id
  http_method          = aws_api_gateway_method.admin-get.http_method
  type                 = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{"statusCode": 200}
EOF
  }
}


resource "aws_api_gateway_integration_response" "admin_integration_response" {

  depends_on = [ aws_api_gateway_method_response.admin_response_200]
  rest_api_id = aws_api_gateway_rest_api.url-shortener-api.id
  resource_id = aws_api_gateway_resource.admin.id
  http_method = aws_api_gateway_method.admin-get.http_method
  status_code = "200"

  # This lines needed to make the html render as webpage otherwise just prints html
  response_parameters = { 
    "method.response.header.Content-Type" = "'text/html'" 
  }

  response_templates = {
    "text/html" = <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Private URL shortener</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
    <script type="text/javascript">

    $(document).ready(function() {

        // used only to allow local serving of files
        $.ajaxSetup({
            beforeSend: function(xhr) {
                if (xhr.overrideMimeType) {
                    xhr.overrideMimeType("application/json");
                }
            }
        });

        $('#url_input').focus();    // set initial focus

        $('form#submit').submit(function(event) {
            $('#url_input_submit').prop('disabled', true);

            // process the form
            $.ajax({
                type        : 'POST',
                url         : '/dev/create',
                data        : JSON.stringify({ 'long_url' : $('#url_input').val(), 'cdn_prefix': window.location.hostname }),
                contentType : 'application/json; charset=utf-8',
                dataType    : 'json',
                encode      : true
            })
            .done(function(data,textStatus, jqXHR) {
                $('#url_input_submit').prop('disabled', false);
                if (data.error) {
                    $('#url-group').addClass('has-error'); // add the error class to show red input
                    $('#url-error').show().text(data.error); // add the actual error message under our input
                } else {
                    $('form#submit').hide();        // hide initial submit form
                    $('form#result').show();        // and show the one used to display the results
                    $('#long_url').text(data.long_url);
                    $('#short_id').val(data.short_id).focus().select();
                }
            })
            .fail(function(_, _, errorThrown) {
                $('#url_input_submit').prop('disabled', false);
                $('#url-group').addClass('has-error'); // add the error class to show red input
                $('#url-error').show().text("Server error: "+errorThrown); // add the actual error message under our input
            });

            // stop the form from submitting the normal way and refreshing the page
            event.preventDefault();
        });
    
        $('form#result').submit(function(event) {
            location.reload();
        });

    });
    </script>
</head>
<body>
<div class="col-sm-8 col-sm-offset-1">

    <h1>Private URL shortener</h1>
    <br/>
    <form id="submit">
        <div id="url-group" class="form-group">
            <input type="url" required class="form-control" name="url" placeholder="Paste here the long URL here" id="url_input">
            <div class="help-block" style="display: none" id="url-error"></div>
        </div>
        <button type="submit" class="btn btn-success" id="url_input_submit">Shorten</button>

    </form>
    <form id="result" style="display: none">
        <div class="alert alert-success">Successfully shortened: <br/><span id="long_url"></span></div>
        <div class="form-group">
            <label for="name">You can now copy/paste the short URL</label>
            <input type="text" class="form-control" name="url" readonly="readonly" id="short_id">
        </div><button type="submit" class="btn btn-success" id="page_reload">New URL</button><div>
        </div>
    </form>

</div>
</body>
</html>
}
EOF
 }
}




# GET SHORT LINK METHOD


resource "aws_api_gateway_resource" "short" {
  rest_api_id = aws_api_gateway_rest_api.url-shortener-api.id
  parent_id   = aws_api_gateway_rest_api.url-shortener-api.root_resource_id
  path_part   = "short"
}

resource "aws_api_gateway_resource" "shortid" {
  rest_api_id = aws_api_gateway_rest_api.url-shortener-api.id
  parent_id   = aws_api_gateway_resource.short.id
  path_part   = "{shortid}"
}

resource "aws_api_gateway_method" "short-get" {
  rest_api_id   = aws_api_gateway_rest_api.url-shortener-api.id
  resource_id   = aws_api_gateway_resource.shortid.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "short_response_301" {

  depends_on = [ aws_api_gateway_method.short-get ]
  rest_api_id   = aws_api_gateway_rest_api.url-shortener-api.id
  resource_id   = aws_api_gateway_resource.shortid.id
  http_method   = "GET"
  status_code = "301"

  response_parameters = {
    "method.response.header.Location"     = true
  }
}


resource "aws_api_gateway_integration" "short_integration" {
  
  rest_api_id          = aws_api_gateway_rest_api.url-shortener-api.id
  resource_id          = aws_api_gateway_resource.shortid.id
  http_method          = aws_api_gateway_method.short-get.http_method
  
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.url-shortener-retrieve2.invoke_arn

  request_templates = {
    "application/json" = <<EOF
{
    "short_id": "$input.params('shortid')"
}
EOF
  }
}



resource "aws_api_gateway_integration_response" "short_integration_response" {
  depends_on = [ aws_api_gateway_integration.short_integration ]
  rest_api_id = aws_api_gateway_rest_api.url-shortener-api.id
  resource_id = aws_api_gateway_resource.shortid.id
  http_method = aws_api_gateway_method.short-get.http_method
  status_code = "301"
  

   response_parameters = { 
    "method.response.header.Location" = "integration.response.body.location" 
   }
}




# CREATE SHORT LINK METHOD

# GET SHORT LINK METHOD


resource "aws_api_gateway_resource" "create" {
  rest_api_id = aws_api_gateway_rest_api.url-shortener-api.id
  parent_id   = aws_api_gateway_rest_api.url-shortener-api.root_resource_id
  path_part   = "create"
}


resource "aws_api_gateway_method" "create-post" {
  rest_api_id   = aws_api_gateway_rest_api.url-shortener-api.id
  resource_id   = aws_api_gateway_resource.create.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "create_response" {

  depends_on = [ aws_api_gateway_method.create-post ]
  rest_api_id   = aws_api_gateway_rest_api.url-shortener-api.id
  resource_id   = aws_api_gateway_resource.create.id
  http_method   = "POST"
  status_code = "200"

  response_parameters = {
    "method.response.header.Location"     = true
  }
}


resource "aws_api_gateway_integration" "create_integration" {
  
  rest_api_id          = aws_api_gateway_rest_api.url-shortener-api.id
  resource_id          = aws_api_gateway_resource.create.id
  http_method          = aws_api_gateway_method.create-post.http_method
  
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.url-shortener-create2.invoke_arn

}





# DEPLOYMENT and STAGING
resource "aws_api_gateway_deployment" "deploy" {
  depends_on = [ aws_api_gateway_integration.admin_integration, aws_api_gateway_integration.short_integration, aws_api_gateway_integration.create_integration ]

  rest_api_id = aws_api_gateway_rest_api.url-shortener-api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.url-shortener-api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "dev-stage" {
  depends_on = [ aws_api_gateway_deployment.deploy ]
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id   = aws_api_gateway_rest_api.url-shortener-api.id
  stage_name    = "dev"
}