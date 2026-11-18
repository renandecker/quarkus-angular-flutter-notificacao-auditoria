package br.com.poc.usuarios;

import java.io.IOException;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.container.ContainerResponseContext;
import javax.ws.rs.container.ContainerResponseFilter;
import javax.ws.rs.ext.Provider;

/** Header X-Response-Time-ms para provar a latencia do fluxo sincrono. */
@Provider
public class TimingFilter implements ContainerRequestFilter, ContainerResponseFilter {

    private static final String START = "x-start-nanos";

    @Override
    public void filter(ContainerRequestContext request) {
        request.setProperty(START, System.nanoTime());
    }

    @Override
    public void filter(ContainerRequestContext request, ContainerResponseContext response) throws IOException {
        Object start = request.getProperty(START);
        if (start instanceof Long) {
            long ms = (System.nanoTime() - (Long) start) / 1_000_000L;
            response.getHeaders().putSingle("X-Response-Time-ms", String.valueOf(ms));
        }
    }
}
