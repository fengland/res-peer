import type { ApolloClientOptions } from '@apollo/client/core'
import { createHttpLink, InMemoryCache, split } from '@apollo/client/core'
// import type { BootFileParams } from '@quasar/app'
import { GraphQLWsLink } from '@apollo/client/link/subscriptions'
import { createClient } from 'graphql-ws'
import { getMainDefinition } from '@apollo/client/utilities'

export /* async */ function getClientOptions /* options?: Partial<BootFileParams<any>> */() {
/* {app, router, ...} */
  const wsLink = new GraphQLWsLink(
    createClient({
      url: 'ws://localhost:8080/ws'
    })
  )

  const searchParams = new URLSearchParams(window.location.search.replace('?', ''))
  let feedAppID = searchParams.get('feedAppID') as string
  if (!feedAppID) {
    feedAppID = 'e476187f6ddfeb9d588c7b45d3df334d5501d6499b3f9ad5595cae86cce16a65210000000000000000000000e476187f6ddfeb9d588c7b45d3df334d5501d6499b3f9ad5595cae86cce16a65230000000000000000000000'
  }
  let creditAppID = searchParams.get('creditAppID') as string
  if (!creditAppID) {
    creditAppID = 'e476187f6ddfeb9d588c7b45d3df334d5501d6499b3f9ad5595cae86cce16a65010000000000000001000000e476187f6ddfeb9d588c7b45d3df334d5501d6499b3f9ad5595cae86cce16a65030000000000000000000000'
  }
  let mallAppID = searchParams.get('mallAppID') as string
  if (!mallAppID) {
    mallAppID = 'e476187f6ddfeb9d588c7b45d3df334d5501d6499b3f9ad5595cae86cce16a659c0000000000000000000000e476187f6ddfeb9d588c7b45d3df334d5501d6499b3f9ad5595cae86cce16a659e0000000000000000000000'
  }
  let port = searchParams.get('port') as string
  if (!port) {
    port = '8080'
  }

  const httpLink = createHttpLink({
    uri: (operation) => {
      switch (operation.variables.endpoint) {
        case 'feed':
          return 'http://localhost:' + port + '/applications/' + feedAppID
        case 'credit':
          return 'http://localhost:' + port + '/applications/' + creditAppID
        case 'mall':
          return 'http://localhost:' + port + '/applications/' + mallAppID
        default:
          return 'http://localhost:' + port + '/applications/' + feedAppID
      }
    }
  })

  const splitLink = split(
    ({ query }) => {
      const definition = getMainDefinition(query)
      return (
        definition.kind === 'OperationDefinition' &&
        definition.operation === 'subscription'
      )
    },
    wsLink,
    httpLink
  )

  return <ApolloClientOptions<unknown>>Object.assign(
    // General options.
    <ApolloClientOptions<unknown>>{
      link: splitLink,
      cache: new InMemoryCache()
    },

    // Specific Quasar mode options.
    process.env.MODE === 'spa'
      ? {
          //
        }
      : {},
    process.env.MODE === 'ssr'
      ? {
          //
        }
      : {},
    process.env.MODE === 'pwa'
      ? {
          //
        }
      : {},
    process.env.MODE === 'bex'
      ? {
          //
        }
      : {},
    process.env.MODE === 'cordova'
      ? {
          //
        }
      : {},
    process.env.MODE === 'capacitor'
      ? {
          //
        }
      : {},
    process.env.MODE === 'electron'
      ? {
          //
        }
      : {},

    // dev/prod options.
    process.env.DEV
      ? {
          //
        }
      : {},
    process.env.PROD
      ? {
          //
        }
      : {},

    // For ssr mode, when on server.
    process.env.MODE === 'ssr' && process.env.SERVER
      ? {
          ssrMode: true
        }
      : {},
    // For ssr mode, when on client.
    process.env.MODE === 'ssr' && process.env.CLIENT
      ? {
          ssrForceFetchDelay: 100
        }
      : {}
  )
}
