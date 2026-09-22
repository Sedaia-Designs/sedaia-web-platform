/**
 * The root URL for the API endpoints.
 * This variable typically serves as the base path for constructing
 * API requests within the application. It ensures consistency for
 * all service calls by providing a common starting point.
 */
const apiOrigin = import.meta.env.VITE_API_BASE_URL ?? '';
const apiRoot = `${apiOrigin}/v1/portfolio`;

/** Options for requests sent to the Ktor Web API. */
interface AsyncFetchProps {
  /**
   * Route relative to the Ktor API's `/v1/portfolio/` base path.
   *
   * @example `users/1`
   */
  apiRoute: string;

  /** Message used when an unsuccessful HTTP response is received. */
  errorMessage?: string;
}

/**
 * Fetches JSON from the Ktor Web API and returns it as the requested type.
 *
 * Unlike the standard SolidJS template's local `users.json` request, this
 * helper sends requests to the Ktor API. During frontend development, Vite
 * proxies that path to the Ktor server. Production uses `VITE_API_BASE_URL`.
 *
 * @remarks
 * The generic type describes the response to TypeScript but does not validate
 * the JSON at runtime. Callers must choose a type that matches the API response.
 *
 * @typeParam DataType - Expected shape of the JSON response.
 * @param props - API route and optional HTTP error message.
 * @returns A promise containing the parsed JSON response.
 * @throws An {@link Error} when the server returns an unsuccessful HTTP status.
 *
 * @example
 * ```ts
 * const user = await asyncFetch<User>({
 *   apiRoute: 'users/1',
 *   errorMessage: 'Unable to load user',
 * });
 * ```
 */
export async function asyncFetch<DataType>({
  apiRoute,
  errorMessage = 'Failed to fetch data',
}: AsyncFetchProps): Promise<DataType> {
  const parsedRoute = `${apiRoot}/${apiRoute}`;

  const res = await fetch(parsedRoute);

  if (!res.ok) throw new Error(`${errorMessage}: ${res.status}`);

  return (await res.json()) as DataType;
}
