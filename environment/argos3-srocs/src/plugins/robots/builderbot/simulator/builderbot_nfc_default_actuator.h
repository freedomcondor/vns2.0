/**
 * @file <argos3/plugins/robots/builderbot/simulator/builderbot_nfc_default_actuator.h>
 *
 * @author Michael Allwright - <allsey87@gmail.com>
 */

#ifndef BUILDERBOT_NFC_DEFAULT_ACTUATOR_H
#define BUILDERBOT_NFC_DEFAULT_ACTUATOR_H

namespace argos {
   class CBuilderBotNFCDefaultActuator;
   class CRadioEntity;
}

#include <argos3/core/simulator/actuator.h>
#include <argos3/plugins/robots/builderbot/control_interface/ci_builderbot_nfc_actuator.h>
#include <argos3/plugins/simulator/media/radio_medium.h>

namespace argos {

   class CBuilderBotNFCDefaultActuator : public CSimulatedActuator,
                                         public CCI_BuilderBotNFCActuator {
   public:

      CBuilderBotNFCDefaultActuator();

      virtual ~CBuilderBotNFCDefaultActuator() {}

      virtual void SetRobot(CComposableEntity& c_entity);

      virtual void Init(TConfigurationNode& t_tree);

      virtual void Update();

      virtual void Reset();

   private:

      CRadioEntity* m_pcRadioEntity;

      class CTxOperation : public CPositionalIndex<CRadioEntity>::COperation { 
      public:

         CTxOperation(const CRadioEntity& c_tx_radio,
                      const std::list<CByteArray>& lst_tx_data);

         virtual bool operator()(CRadioEntity& c_rx_radio);

      private:

         const CRadioEntity& m_cTxRadio;
         const std::list<CByteArray>& m_lstTxData;

      };
   };
}

#endif
