Location
========

Location is a Rails Engine that aims to provide location related utilities: polymorphic address models,
normalizable address attributes - useful for applications which rely heavily on location databases - flexible
web service integration, form address auto fill, maps (with Google Maps), virtus form objects and so on.
You can use this gem together with any app/table that needs address fields. Some components work without Rails.

This is still a work in progress, no release has been made yet. Some work needs to be done:

- Documentation
- Internationalization for some countries (currently works with pt_BR)
- A default web service implementation (needs to be free of charge)
- Option to use foreign key constraints
- Maps integration: Locate an address on a map using form values
- Form builder helpers for some address fields

That's all for now.
