from chalice import Chalice
import graphene
from sqlalchemy import Column, Integer, Sequence, String, create_engine
from sqlalchemy.orm import relationship, scoped_session, sessionmaker

from graphene_sqlalchemy import SQLAlchemyObjectType

from lib.db import Base

app = Chalice(app_name='api')


class UserModel(Base):
    __tablename__ = 'users'
    # id = Column(Integer, primary_key=True)
    id = Column(Integer, Sequence('users_id_seq'), primary_key=True)
    name = Column(String)


class User(SQLAlchemyObjectType):
    class Meta:
        model = UserModel
        # only return specified fields
        only_fields = ("name",)


class Admin(graphene.ObjectType):
    investors = graphene.List(graphene.NonNull(User))

    def resolve_investors(self, info):
        query = User.get_query(info)
        return query.all()


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
