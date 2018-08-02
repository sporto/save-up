const { ApolloServer, gql } = require('apollo-server-lambda');

// Construct a schema, using GraphQL schema language
const typeDefs = gql`
  type Query {
    hello: String
  }
`;

// Provide resolver functions for your schema fields
const resolvers = {
  Query: {
    hello: () => 'Hello world!',
  },
};

const server = new ApolloServer({ typeDefs, resolvers });

console.log(server)

exports.handler = server.createHandler();

// exports.handler = (event, context, callback) => {
//   console.log('Handler start')

//   callback(null, {
//       statusCode: 200,
//       body: new Date()
//   })
// }
