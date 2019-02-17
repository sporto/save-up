from chalice import Chalice
import graphene

app = Chalice(app_name='api')


class Query(graphene.ObjectType):
    hello = graphene.String(
        argument=graphene.String(default_value="stranger")
    )

    def resolve_hello(self, info, argument):
        return 'Hello ' + argument


schema = graphene.Schema(query=Query)


@app.route('/graphql-app', methods=['POST'])
def index():
    request = app.current_request
    request_body = request.json_body
    query = ''
    variables = {}

    if ('query' in request_body):
        query = request_body['query']

    if ('variables' in request_body):
        variables = request_body['variables']

    result = schema.execute(query, variables=variables)
    # return result
    # responseBody = {
    #     "data": result
    # }
    # print(result.data)
    # return {'hello': 'world'}
    return {'data': result.data}

    # The view function above will return {"hello": "world"}
    # whenever you make an HTTP GET request to '/'.
    #
    # Here are a few more examples:
    #
    # @app.route('/hello/{name}')
    # def hello_name(name):
    #    # '/hello/james' -> {"hello": "james"}
    #    return {'hello': name}
    #
    # @app.route('/users', methods=['POST'])
    # def create_user():
    #     # This is the JSON body the user sent in their POST request.
    #     user_as_json = app.current_request.json_body
    #     # We'll echo the json body back to the user in a 'user' key.
    #     return {'user': user_as_json}
    #
    # See the README documentation for more examples.
    #
