module Data.Service.CalendarEntry ( createEntry, removeCalendar ) where

import Control.Monad.IO.Class

import Data.Domain.User                      as User
import Data.Domain.CalendarEntry             as CalendarEntry
import Data.Repository.Acid.CalendarEntry         ( MonadDBCalendar )
import Data.Repository.Acid.Task                  ( MonadDBTask )
import Data.Repository.Acid.User                  ( MonadDBUser )

import qualified Data.Repository.CalendarRepo         as CalendarRepo
import qualified Data.Repository.TaskRepo             as TaskRepo
import qualified Data.Repository.UserRepo             as UserRepo


createEntry :: (MonadDBUser m, MonadDBCalendar m) =>
            String -> User -> m CalendarEntry
createEntry description user = do
    calendarEntry <- CalendarRepo.newCalendarEntry description user
    UserRepo.addCalendarEntryToUser user $ CalendarEntry.entryId calendarEntry
    return calendarEntry

removeCalendar :: (MonadDBUser m, MonadDBTask m, MonadDBCalendar m, MonadIO m) =>
                CalendarEntry -> m ()
removeCalendar calendarEntry = let cEntryId = entryId calendarEntry in
    do
       user <- UserRepo.getUser (CalendarEntry.userId calendarEntry)
       UserRepo.deleteCalendarEntryFromUser user cEntryId
       deleteCalendarsTasks calendarEntry
       CalendarRepo.deleteCalendarEntry cEntryId

deleteCalendarsTasks :: (MonadDBTask m, MonadDBCalendar m, MonadIO m)
                => CalendarEntry -> m ()
deleteCalendarsTasks calendar =
    foldr (\ x ->
      (>>) (do
        task <- TaskRepo.getTask x
        TaskRepo.deleteTask task ))
    (return ()) $ CalendarEntry.tasks calendar