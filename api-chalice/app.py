from chalice import Chalice
import graphene

app = Chalice(app_name='api')


class User(graphene.ObjectType):
    name = graphene.String()

    def resolve_name(self, info):
        return "Sam Sample"


class Admin(graphene.ObjectType):
    investors = graphene.List(graphene.NonNull(User))

    def resolve_investors(self, info):
        return []


class AppQuery(graphene.ObjectType):
    admin = graphene.NonNull(Admin)

    def resolve_admin(self, into):
        return Admin()

    hello = graphene.String(
        argument=graphene.String(default_value="stranger")
    )

    def resolve_hello(self, info, argument):
        return 'Hello ' + argument


app_schema = graphene.Schema(query=AppQuery)


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

    result = app_schema.execute(query, variables=variables)

    return {'data': result.data}
