import { color } from 'd3'
import { getRdfType } from 'shared/helpers/rdf_types'
import colors from 'shared/ui/colors'

/** Shared definitions **/

const _adam = {
  icon: 'icon-adam',
  char: '\ue910',
  color: colors.primaryLight
}

const _sdtm = {
  icon: 'icon-sdtm',
  char: '\ue911',
  color: colors.primaryLight
}

/**
 * Defines an RDF Type - Icon, Char & Color map
 */
const rdfMap = {

  // Thesaurus and CL Types

  [getRdfType('TH')]: {
    icon: 'icon-terminology',
    char: '\ue909',
    color: colors.primaryLight
  },
  [getRdfType('TH_CL')]: {
    icon: 'icon-codelist',
    char: '\ue952',
    color: colors.primaryBright
  },
  [ getRdfType('TH_SUBSET') ]: {
    icon: 'icon-subset',
    char: '\ue941',
    color: colors.primaryBright
  },
  [ getRdfType('TH_EXT') ]: {
    icon: 'icon-extension',
    char: '\ue945',
    color: colors.primaryBright
  },
  [ getRdfType('TH_CLI') ]: {
    icon: 'icon-codelist-item',
    char: '\ue958',
    color: colors.primaryBright
  },

  // Managed Item Types

  [ getRdfType('MC') ]: {
    icon: 'icon-collection',
    char: '\ue973',
    color: colors.oliveGreen
  },
  [ getRdfType('FORM') ]: {
    icon: 'icon-forms',
    char: '\ue91c',
    color: colors.accentAqua
  },
  [ getRdfType('BC') ]: {
    icon: 'icon-biocon',
    char: '\ue90b',
    color: colors.accentPurple
  },
  [ getRdfType('BCT') ]: {
    icon: 'icon-biocon-template',
    char: '\ue969',
    color: colors.accentPurpleLight
  },
  [ getRdfType('ADAM_IG') ]: _adam,
  [ getRdfType('ADAM_DATASET') ]: _adam,
  [ getRdfType('SDTM_MODEL') ]: _sdtm,
  [ getRdfType('SDTM_IG') ]: _sdtm,
  [ getRdfType('SDTM_DOMAIN') ]: _sdtm,
  [ getRdfType('SDTM_CLASS') ]: _sdtm,
  [ getRdfType('SDTM_SD') ]: _sdtm,

  // Form Sub Types

  [ getRdfType('NORMAL_GROUP') ]: {
    icon: 'icon-group',
    char: '\ue970',
    color: colors.primaryBright
  },
  [ getRdfType('COMMON_GROUP') ]: {
    icon: 'icon-common-group',
    char: '\ue96f',
    color: colors.primaryBrightest
  },
  [ getRdfType('BC_GROUP') ]: {
    icon: 'icon-biocon',
    char: '\ue90b',
    color: colors.accentPurple
  },
  [ getRdfType('COMMON_ITEM') ]: {
    icon: 'icon-common-biocon',
    char: '\ue96e',
    color: colors.primaryBrightest
  },
  [ getRdfType('TEXTLABEL') ]: {
    icon: '',
    char: 'L',
    color: colors.greyLight
  },
  [ getRdfType('PLACEHOLDER') ]: {
    icon: '',
    char: 'P',
    color: colors.greyLight
  },
  [ getRdfType('QUESTION') ]: {
    icon: '',
    char: 'Q',
    color: colors.accentAquaDark
  },
  [ getRdfType('MAPPING') ]: {
    icon: '',
    char: 'M',
    color: colors.oliveGreen
  },
  [ getRdfType('BC_PROPERTY') ]: {
    icon: 'icon-biocon',
    char: '\ue90b',
    color: colors.accentPurpleLight
  },
  [ getRdfType('TC_REF') ]: {
    icon: 'icon-codelist',
    char: '\ue952',
    color: colors.primaryBright
  },
  [ getRdfType('TUC_REF') ]: {
    icon: 'icon-codelist-item',
    char: '\ue958',
    color: colors.primaryBright
  },

  unknown: {
    icon: 'icon-help',
    char: '\ue94e',
    color: colors.greyLight
  }

}

export default rdfMap