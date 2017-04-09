/**
 * Created by Azat on 26.03.2017.
 */

package com.spbpu.user;

import com.spbpu.exceptions.NoRightsException;
import com.spbpu.exceptions.NotAuthenticatedException;
import com.spbpu.project.Ticket;

public interface TicketDeveloper extends UserInterface {

    default void notifyNew(Ticket ticket) {}

    default void acceptTicket(Ticket ticket) throws NoRightsException, NotAuthenticatedException {
        checkAuthenticated();
        ticket.setAccepted(this);
    }

    default void setInProgress(Ticket ticket) throws NoRightsException, NotAuthenticatedException {
        checkAuthenticated();
        ticket.setInProgress(this);
    }

    default void finishTicket(Ticket ticket) throws NoRightsException, NotAuthenticatedException {
        checkAuthenticated();
        ticket.setFinished(this);
    }

    default void commentTicket(Ticket ticket, String comment) throws NoRightsException, NotAuthenticatedException {
        checkAuthenticated();
        ticket.addComment(this, comment);
    }
}
