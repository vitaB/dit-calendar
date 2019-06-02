{-# LANGUAGE MultiParamTypeClasses #-}
module Presentation.Mapper.CalendarEntryMapper
    ( Mapper(..)
    ) where

import           Data.Default
import           Data.Generics.Aliases          (orElse)
import           Data.Maybe                     (fromMaybe)

import qualified Data.Domain.CalendarEntry      as Domain
import           Presentation.Dto.CalendarEntry
import           Presentation.Mapper.BaseMapper

instance Mapper Domain.CalendarEntry CalendarEntry where
    transformToDto domain =
        CalendarEntry
            { description = Just (Domain.description domain)
            , entryId = Just (Domain.entryId domain)
            , version = Just $ Domain.version domain
            , tasks = Just (Domain.tasks domain)
            , date = Domain.date domain
            }

    transformFromDto dto mDbCalendar =
        case mDbCalendar of
            Nothing ->
                def
                    { Domain.entryId = 0
                    , Domain.version = 0
                    , Domain.description = fromMaybe (error "description is missing") (description dto)
                    , Domain.tasks = fromMaybe [] (tasks dto)
                    , Domain.date = date dto
                    }
            Just dbCalendar ->
                def
                    { Domain.description = fromMaybe (Domain.description dbCalendar) (description dto)
                    , Domain.entryId = Domain.entryId dbCalendar
                    , Domain.version = fromMaybe (error "version is missing") (version dto)
                    , Domain.tasks = fromMaybe (Domain.tasks dbCalendar) (tasks dto)
                    , Domain.date = date dto
                    }